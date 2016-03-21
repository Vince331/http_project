require 'socket'
require 'notes/parser'

class Notes
  class Server
    attr_accessor :server

    def initialize(hash, app = nil)
      @server = TCPServer.new hash[:Host], hash[:Port]
      @app =  app
    end

    def stop
      @server.close
    end

    def start
      loop do
        socket = @server.accept
        env = Parser.new(socket).call
        response_code, headers, body = @app.call(env)
        Notes::Server.printer(socket, response_code, headers, body)
      end
    end

    def self.printer(socket, response_code, headers, body)
      socket.print "HTTP/1.1 " + response_code.to_s + "\r\n"
      socket.print headers.map { |k, v| "#{k}: #{v}" }.join("\r\n") + "\r\n\r\n"
      socket.print body.join
      socket.close
    end
  end
end
