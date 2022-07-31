require 'async'
require 'async/io/stream'
require 'async/http/endpoint'
require 'async/websocket/client'
require 'openssl'
require 'forwardable'
require 'base64'

class String
  def to_64
    Base64.encode64 self
  end

  def from_64
    Base64.decode64 self
  end
end


NICK = ARGV.pop || "ruby-user"
URL = ARGV.pop || "http://localhost:8887"

class User
  attr_reader :key, :nick

  def initialize nick
    @nick = nick
    set_key
  end

  def sign_message text
    @key.sign 'SHA256', text
  end

  private

  def set_key
    cfg_name = ".eternal_key_of_stoat"
    unless File.exist? File.join __dir__, cfg_name
      File.open(File.join(__dir__, cfg_name), 'w') do |cfg|
        cfg << Marshal.dump(OpenSSL::PKey::RSA.new(2048))
      end
    end

    @key = Marshal.restore File.read(File.join(__dir__, cfg_name))

  end

  def pubkey
    @key.public_key.to_s.to_64
  end

  class Message
    extend Forwardable

    def_delegators :@user, :pubkey, :nick
    attr_reader :text

    def initialize user, text
      @user = user
      @text = text
    end

    def format
      {
        type: 'message',
        data: {
          text:,
          pubkey:,
          signature:,
          nick:
        }
      }
    end

    def signature
      @user.key.sign('SHA256', @text).to_64
    end
  end
end

def print_message(message_data)
  puts "<#{message_data[:time]}>[#{message_data[:nick]}]: #{message_data[:text]}"
end

def handle_server_message(message)
  case message[:type]
  when 'history'
    message[:data].each{print_message _1}
  when 'message'
    print_message message[:data]
  else
    puts "<<unknown data>>"
    pp message
  end
end

def start_client
  user = User.new(NICK)

  Async do |task|
    stdin = Async::IO::Stream.new(
      Async::IO::Generic.new($stdin)
    )
    
    endpoint = Async::HTTP::Endpoint.parse(URL)
    
    Async::WebSocket::Client.connect(endpoint) do |connection|
      input_task = task.async do
        while line = stdin.read_until("\n")
          connection.write(User::Message.new(user, line).format)
          connection.flush
        end
      end
      
      connection.write({
        type: "history_request",
        data: {}
      })
      
      while message = connection.read
        handle_server_message message
      end
    ensure
      input_task&.stop
    end
  end
end


start_client