require 'socket'

class Notes
  class Web
    attr_accessor :server

    def initialize(app, hash)
      @server = TCPServer.new hash[:Host], hash[:Port]
      @app =  app
    end

    def stop
      @server.close
    end

    def start
      loop do
      socket = @server.accept
      inline  = socket.gets
      response_code, headers, body = @app.call(inline)
      header = "HTTP/1.1 "+response_code.to_s+" OK\r\n" +
      headers.map{ |k,v| "#{k}: #{v}"}.join("\r\n")
      socket.print header
      socket.print "\r\n\r\n"
      socket.print body.join
      socket.close
      end
    end
  end
end
