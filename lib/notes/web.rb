require 'socket'

class Notes
  class Web

   FORM = "<form action='/search' method='GET'>
           <input type='text' name='query'>
           <input type='Submit'>
           </form>"
    NOTES = ['Add 1 to 2    1 + 2  # => 3',
            'Subtract 5 from 2    2 - 5  # => -3',
            'Is 1 less than 2    1 < 2  # => true',
            'Is 1 equal to 2    1 == 2 # => 3',
            'Is 1 greater than 2    1 > 2  # => 3',
            'Is 1 less than or equal to 2    1 <= 2 # => 3',
            'Is 1 greater than or equal to 2    1 >= 2 # => 3',
            'Convert 1 to a float        1.to_f # => 3',
            'Concatenate two arrays    [1,2] + [2, 3]   # => [1, 2, 2, 3]',
            'Remove elements in second array from first    [1,2,4] - [2, 3] # => [1,4]',
            'Access an element in an array by its index    ["a","b","c"][0] # => "a"',
            'Find out how big the array is    ["a","b"].length # => 2']

    attr_accessor :server

    def initialize(app = nil, hash)
      @server = TCPServer.new hash[:Host], hash[:Port]
      @app =  app
      @form = FORM
      @notes = NOTES
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

      if query.length > 0
       result = NOTES
       query.select do |elem|
        result = result.select do |x|

          x.upcase.include? elem.upcase
        end
        end

        @form  = result.join("<br>")
      else
        @form = FORM
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

      require "pry"
      binding.pry
      env = check.merge(env)
    end

    def own_app
      loop do
        socket = @server.accept
        env = parser(socket)
        socket.print "HTTP/1.1 200 OK\r\n"
        socket.print "Content-Type: text/html\r\n"
        socket.print "Content-Length: #{@form.length}\r\n"
        socket.print "\r\n"
        socket.puts @form
        socket.close
      end
    end

  end

end
