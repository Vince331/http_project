require 'socket'

class Notes
  class Web
    attr_accessor :server #, :app

    def initialize(app = nil, hash)
      @server = TCPServer.new hash[:Host], hash[:Port]
      # @app = app
      @app = Proc.new do |env|
          [200, {'Content-Type' => 'text/html', 'Content-Length' => body.length}, body]
       end
    end

    form = "<form>
              search:
              <input type='text' name'query'>
              </form>
    "

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

        require "pry"
        binding.pry
        response_code, headers, body = @app.call(check)
        header = "HTTP/1.1 "+response_code.to_s+" OK\r\n" +
          headers.map{ |k,v| "#{k}: #{v}"}.join("\r\n")
        socket.print header
        socket.print "\r\n\r\n"
        socket.print body.join
        socket.close
      end
    end

    def test

    end


    def parser(final)

      firstline = final.shift

      first_line = firstline.split(" ")
      check = {"REQUEST_METHOD" => first_line[0],
               "PATH_INFO" => first_line[1],
               "SERVER_PROTOCOL"=> first_line[2]}
    end
  end
end

server = Notes::Web.new(Host: 'localhost', Port: 9999)
server.start

