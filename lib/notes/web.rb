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
               "SERVER_PROTOCOL"=> first_line[2],
               "HTTP_VERSION"=> first_line[2]}
      query = []
      #second_line = final[1].split(":",3)
      if first_line[1].include?("?")
        query  = check["PATH_INFO"][/=.*/][1..-1].split("+")
        check["QUERY_STRING"] = query
      else
        check["QUERY_STRING"] = ""
      end
      array = final.map do |x|
        x.chomp.split(": ",2)
      end
      i = 0
      env = {}
      while i < array.length
        if array[i][0] == nil
        else
          array[i][0]  = "HTTP_#{array[i][0]}" unless array[i][0]  == 'CONTENT_TYPE' || array[i][0] == 'CONTENT_LENGTH'
          env[(array[i][0]).upcase.tr("-", "_")] = array[i][1]
        end
        i+=1
      end
      env = check.merge(env)
    end

    def self.parser(socket)
      final = []
      final << socket.gets
      while final[-1] != "\r\n"
        final << socket.gets
      end
      first_line = final.shift
      first_line = first_line.split(" ")
      check = {"REQUEST_METHOD" => first_line[0],
               "PATH_INFO" => first_line[1],
               "SERVER_PROTOCOL"=> first_line[2],
               "HTTP_VERSION"=> first_line[2]}
      query = []
      #second_line = final[1].split(":",3)
      if first_line[1].include?("?")
        query  = check["PATH_INFO"][/=.*/][1..-1].split("+")
        check["QUERY_STRING"] = query
      else
        check["QUERY_STRING"] = ""
      end

      array = final.map do |x|
        x.chomp.split(": ",2)
      end

      i = 0
      env = {}
      while i < array.length
        if array[i][0] == nil
        else
          array[i][0]  = "HTTP_#{array[i][0]}" unless array[i][0]  == 'CONTENT_TYPE' || array[i][0] == 'CONTENT_LENGTH'
          env[(array[i][0]).upcase.tr("-", "_")] = array[i][1]
        end
        i+=1
      end
      env = check.merge(env)
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
end
