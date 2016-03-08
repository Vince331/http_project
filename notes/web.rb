require 'socket'

class Notes
    class Web
      attr_accessor :server

      def initialize(app, hash)
        @server = TCPServer.new hash[:Host], hash[:Port]
        @request =  app.call
       # socket.gets
       # socket.read
       # socket.print "hello!"
      end

      def stop
      end

      def start
        socket = server.accept
        # while line = socket.gets
        #   puts line
        # end
        # line_1 = socket.gets
        # line_2 = socket.read 10
        socket.print @request[0]
        socket.close
        server.close
      end
    end
end
