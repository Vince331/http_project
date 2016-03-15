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
        env = parser(socket)
        response_code, headers, body = @app.call(env)
        header = "HTTP/1.1 "+response_code.to_s+" OK\r\n" +
          headers.map{ |k,v| "#{k}: #{v}"}.join("\r\n")
        socket.print header
        socket.print "\r\n\r\n"
        socket.print body.join
        socket.close
      end
    end

    def parser(socket)

      final = []
      final << socket.gets
      while final[-1] != "\r\n"
        final << socket.gets
      end
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
      check
      final.each do |line|
        line.split(":")
        line
      end
    end

    def own_app
      loop do
        socket = @server.accept
        env = parser(socket)
        socket.print "HTTP/1.1 200 OK\r\n"
        socket.print "Content-Type: text/html\r\n"
        socket.print "Content-Length: 125\r\n"
        socket.print "\r\n"
        socket.puts "<form action='/search' method='GET'>"
        socket.puts "<input type='text' name='query'></input>"
        socket.puts "<input type='Submit'></input>"
        socket.puts "</form>"
        socket.puts "\r\n\r\n"
        socket.close
      end
    end

  end
  #end Web
end
#end Notes

#server = Notes::Web.new(Port: 6969, Host: 'localhost')
#server.own_app
