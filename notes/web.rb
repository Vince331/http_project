require 'socket'

class Notes
    class Web
      attr_accessor :server

      def initialize(app, hash)
        @server = TCPServer.new hash[:Host], hash[:Port]

        @app =  app
       # require "pry"
       # binding.pry
       # socket.gets
       # socket.read
       # socket.print "hello!"
       # start
      end

      def stop
      end

      def start


       socket = @server.accept

       require "pry"
       binding.pry

        while socket.gets
        socket.gets
        end

        require "pry"
        binding.pry
        response_code, headers, body = @app.call
      header =  "HTTP/1.1 "+response_code.to_s+" OK\r\n" +
          headers.map{ |k,v| "#{k}: #{v}"}.join("\r\n")

        socket.print header

        socket.print "\r\n\r\n"

        socket.print body

        socket.close


     #  socket.gets
     #  socket.gets
     #  socket.gets
     #  socket.gets
     #  socket.gets
     #  socket.gets



     # socket.print "HTTP/1.1 200 Moved Permanently\r\n"
     # socket.print "Content-Type: text/html\r\n"
     # socket.print "Content-Length: 5\r\n"
     # socket.print "omg: hi\r\n"
     # socket.print "\r\n"
     # socket.print "hello"

     # socket.close
      @server.close


      # socket.close
       # socket.print @request[0]
      end
    end
end
