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

      final = []
      final << socket.gets
      while final[-1] != "\r\n"
        final << socket.gets
      end

     # require "pry"
     # binding.pry

      check = parser(final)



      response_code, headers, body = @app.call(check)
      header = "HTTP/1.1 "+response_code.to_s+" OK\r\n" +
      headers.map{ |k,v| "#{k}: #{v}"}.join("\r\n")
      socket.print header
      socket.print "\r\n\r\n"
      socket.print body.join
      socket.close
      end

    end


      def parser(final)

      first_line = final.shift
      first_line = first_line.split(" ")
      check = {"REQUEST_METHOD" => first_line[0],
      "PATH_INFO" => first_line[1],
      "SERVER_PROTOCOL"=> first_line[2]}

     # require "pry"
     # binding.pry
#   .map{ |k,v| "#{k}: #{v}"}.join("\r\n")
      check
      end



    end
  end


# server = Notes::Web.new(app, Port: port, Host: 'localhost')
#    thread = Thread.new { server.start } # The thread allows the server to sit and wait for a request, but still return to here so we can send it.
#    thread.abort_on_exception = true

