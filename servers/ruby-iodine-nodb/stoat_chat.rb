require 'yaml/store'
require 'securerandom'
require 'iodine'
require 'json'
require 'time'
require 'openssl'
require 'base64'


### Models ###

User = Struct.new :nick, :pubkey, keyword_init: true do
  def initialize(*)
    super
    Users.add self
  end

  def id() = pubkey
  def id=(v)
    self.pubkey = v
  end
end

Message = Struct.new :text, :signature, :pubkey, :time, :nick, keyword_init: true do
  attr_accessor :id
  
  def initialize(*args, **kwargs)
    super *args, **kwargs
    self.id ||= SecureRandom.random_number 100000000000000000000000000000
    self.time ||= Time.now.iso8601

    !!kwargs[:nick] and user&.nick = kwargs[:nick]
    Messages.add self
  end

  def user() = @user ||= Users.fetch_or_create(pubkey)

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

### Persistant storage ###

$store = YAML::Store.new 'store.yaml', thread_safe: true

$store.transaction do
  $store["messages"] ||= {}
  $store["users"] ||= {}
end

### Model collections ###

module BaseCollection
  def all
    $store.transaction {$store[name]}
  end

  def add item
    $store.transaction {$store[name][item.id] = item}
    item
  end

  def name
    @name or raise '@name not defined in subclass!'
  end
end

class Users
  @name = 'users'
  extend BaseCollection

  class << self
    def fetch_or_create key
      user = all[key]
      return user if user

      add User.new(pubkey: key)
    end
  end
end

class Messages
  @name = 'messages'
  extend BaseCollection
end

### Server ###

module ChatServer
  extend self

  def on_open client
    client.subscribe :chat
    puts "Client connected: #{client.inspect}"
    client.publish :chat, {type: 'response', message: 'Yay, you are connected!', status: :ok}
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
      pp body
      msg.authentic? or raise 'authtication error!'
      Messages.add msg
      client.publish :chat, {type: 'message', data: msg.serialize}.to_json
    end,
    'history_request' => lambda do |client, data|
      client.write(:chat, {
        type: 'history',
        data: Messages.all.values.sort_by{Time.parse _1.time}.map(&:serialize)
      }.to_json)
    end,
    'users_request' => lambda do |client, data|
      client.write(:chat, 'tough luck')
    end
  }

  HANDLERS.default = lambda do |client, data|
    warn "Received message that I can't handle!"
    pp data
    client.publish :chat, {type: 'response', message: "I don't know how to interact with that...", status: :error}.to_json
  end
end

APP = Proc.new do |env|
  return [200,{},[]] unless env['rack.upgrade?'] == :websocket

  env['rack.upgrade'] = ChatServer
  [0,{},[]]
end
