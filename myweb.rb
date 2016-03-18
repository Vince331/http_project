require 'socket'

class Notes
  class Web
    attr_accessor :server

    def initialize(app = nil, hash, &block)
      @server = TCPServer.new hash[:Host], hash[:Port]
      @app = Proc.new do |env|
        body = "<form action='/search' method='get'>
  <input type='textarea' name='query'>
  <input type='Submit'>
</form>"
        [200, {'Content-Type' => 'text/html', 'Content-Length' => body.length}, body]
      end
    end

    def stop
      @server.close
    end

    def start
      loop do
        socket = @server.accept
        final = []
        final << socket.gets
        while final[-1] != "\r\n"
          final << socket.gets
        end

        check = parser(final)
        response_code, headers, body = @app.call(check)
        header = "HTTP/1.1 "+response_code.to_s+" OK\r\n" +
          headers.map{ |k,v| "#{k}: #{v}"}.join("\r\n")
        socket.print header
        socket.print "\r\n\r\n"
        socket.print body
        socket.close
      end
    end

    def parser(final)

      firstline = final.shift

      first_line = firstline.split(" ")
      check = {"REQUEST_METHOD" => first_line[0],
               "PATH_INFO" => first_line[1],
               "SERVER_PROTOCOL"=> first_line[2]}
      if first_line}
    end
  end
end

server = Notes::Web.new(Host: 'localhost', Port: 9999)
server.start

