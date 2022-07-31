require 'securerandom'
require 'json'
require 'time'
require 'openssl'
require 'base64'
Bundler.require


### DB Connection ###

$db = Sequel.sqlite('detabesu.sqlite')

### Schema & Models ###

$db.create_table? :users do
  primary_key :id
  String :nick
  String :pubkey, index: true
end

$db.create_table? :messages do
  primary_key :id
  Integer :user_id
  String :text
  String :signature
  String :pubkey, index: true
  String :time
  String :nick
  DateTime :date
end

class User < Sequel::Model(:users)
  one_to_many :messages
end

class Message < Sequel::Model(:messages)
  many_to_one :user
  def before_create
    self.time = Time.now
  end

  def authentic?
    digest = OpenSSL::Digest.new('SHA256')
    pkey = OpenSSL::PKey::RSA.new decoded_pub
    pkey.verify digest, decoded_sig, text
  end

  def decoded_pub
    Base64.decode64 pubkey
  end

  def decoded_sig
    Base64.decode64 signature
  end

  def serialize
    {
      text: text,
      pubkey: pubkey,
      signature: signature,
      nick: user.nick,
      id: id,
      time: time
    }
  end
end

### Server ###

module ChatServer
  extend self

  def on_open client
    client.subscribe :chat
    puts "Client connected: #{client.inspect}"
    client.publish :chat, {type: 'response', message: 'Yay, you are connected!', status: :ok}.to_json
  end

  def on_close client
    puts "Client disconnected: #{client.inspect}"
  end

  def on_message client, data
    parsed = JSON.parse data, symbolize_names: true
    puts "received data: #{parsed}"
    HANDLERS[parsed[:type].to_s].call client, parsed
  rescue JSON::ParserError
    warn "Parsing error: #{data}"
  end

  HANDLERS = {
    'message' => lambda do |client, data|
      body = data[:data]
      msg = Message.new(**body.slice(:text, :signature, :pubkey, :nick))
      user = User.find_or_create(pubkey: msg.pubkey)
      user.nick = body[:nick]
      user.save
      msg.user = user
      pp body
      msg.authentic? or raise 'authtication error!'
      msg.save
      client.publish :chat, {type: 'message', data: msg.serialize}.to_json
    end,
    'history_request' => lambda do |client, data|
      client.write({
        type: 'history',
        data: Message.all.map(&:values)
      }.to_json)
    end,
    'users_request' => lambda do |client, data|
      client.write({}.to_json)
    end
  }

  HANDLERS.default = lambda do |client, data|
    warn "Received message that I can't handle!"
    pp data
    client.publish :chat, {type: 'response', message: "I can't interact with that!", status: :error}.to_json
  end
end

APP = Proc.new do |env|
  return [200,{},[]] unless env['rack.upgrade?'] == :websocket

  env['rack.upgrade'] = ChatServer
  [0,{},[]]
end
