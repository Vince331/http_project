require 'socket'



class Notes
  class Web
    attr_accessor :server

    def initialize(app = nil, hash)
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
      query = []
      if first_line[1].include?("?")
        query  = check["PATH_INFO"][/=.*/][1..-1].split("+")
        check["QUERY_STRING"] = query
      else
        check["QUERY_STRING"] = ""
      end



     # require "pry"
     # binding.pry
     # .map{ |k,v| "#{k}: #{v}"}.join("\r\n")
      check
      end



      def own_app
          loop do
          socket = @server.accept
          final = []
          final << socket.gets
          while final[-1] != "\r\n"
            final << socket.gets
          end
          check = parser(final)
          socket.print "HTTP/1.1 200 OK\r\n"
          socket.print "Content-Type: text/html\r\n"
          socket.print "Content-Length: 125\r\n"
          socket.print "\r\n"
          socket.puts "<form action='/search' method='GET'>"
          socket.puts "<input type='text' name='query'></input>"
          socket.puts "<input type='Submit'></input>"
          socket.puts "</form>"
          socket.puts "\r\n\r\n"

          require "pry"
          binding.pry
          socket.close
          end
       #   app = Proc.new do |env_hash|
       #     path_info = env_hash['PATH_INFO']
       #     body      = "hello, class ^_^"
       #     [200, {'Content-Type' => 'text/plain', 'Content-Length' => body.length, 'omg' => 'bbq'}, [body]]
       #     socket.close

        #  end
      end


      def app_two





      end

  end
  #end Web
end
#end Notes

# server = Notes::Web.new(app, Port: port, Host: 'localhost')
#    thread = Thread.new { server.start } # The thread allows the server to sit and wait for a request, but still return to here so we can send it.
#    thread.abort_on_exception = true
server = Notes::Web.new(Port: 6969, Host: 'localhost')
server.own_app
