require 'socket'

class Notes
  class Web
    attr_accessor :server

    def initialize(app = nil, hash)
      @server = TCPServer.new hash[:Host], hash[:Port]
      @app =  app
       @form = "<form action='/search' method='GET'>
                     <input type='text' name='query'>
                     <input type='Submit'>
                     </form>"

        @notes = 'Add 1 to 2    1 + 2  # => 3,\r\n
                 Subtract 5 from 2    2 - 5  # => -3,\r\n
                 Is 1 less than 2    1 < 2  # => true,\r\n
                 Is 1 equal to 2    1 == 2 # => 3,\r\n
                 Is 1 greater than 2    1 > 2  # => 3,\r\n
                 Is 1 less than or equal to 2    1 <= 2 # => 3,\r\n
                 Is 1 greater than or equal to 2    1 >= 2 # => 3,\r\n
                 Convert 1 to a float        1.to_f # => 3,\r\n
                 Concatenate two arrays    [1,2] + [2, 3]   # => [1, 2, 2, 3],\r\n
                 Remove elements in second array from first    [1,2,4] - [2, 3] # => [1,4],\r\n
                 Access an element in an array by its index    ["a","b","c"][0] # => "a",\r\n
                 Find out how big the array is    ["a","b"].length # => 2'
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

      array = final.map do |x|
        x.chomp.split(": ",2)
      end

      if check["QUERY_STRING"].length > 0
        @form = @notes
      end

      i = 0
      env = {}
      while i < array.length
        if array[i][0] == nil
        else
          env[(array[i][0]).upcase] = array[i][1]
        end
        i+=1
      end
     env = check.merge(env)
    end

    def own_app
      loop do
        socket = @server.accept
        env = parser(socket)
        # form = "<form action='/search' method='GET'>
        #              <input type='text' name='query'>
        #              <input type='Submit'>
        #              </form>"

        # notes = ['Add 1 to 2    1 + 2  # => 3',
        #          'Subtract 5 from 2    2 - 5  # => -3',
        #          'Is 1 less than 2    1 < 2  # => true',
        #          'Is 1 equal to 2    1 == 2 # => 3',
        #          'Is 1 greater than 2    1 > 2  # => 3',
        #          'Is 1 less than or equal to 2    1 <= 2 # => 3',
        #          'Is 1 greater than or equal to 2    1 >= 2 # => 3',
        #          'Convert 1 to a float        1.to_f # => 3',
        #          'Concatenate two arrays    [1,2] + [2, 3]   # => [1, 2, 2, 3]',
        #          'Remove elements in second array from first    [1,2,4] - [2, 3] # => [1,4]',
        #          'Access an element in an array by its index    ["a","b","c"][0] # => "a"',
        #          'Find out how big the array is    ["a","b"].length # => 2']


        socket.print "HTTP/1.1 200 OK\r\n"
        socket.print "Content-Type: text/html\r\n"
        socket.print "Content-Length: #{@form.length}\r\n"
        socket.print "\r\n"
        socket.puts @form
        socket.close
      end
    end

  end
  #end Web
end
#end Notes

 server = Notes::Web.new(Port: 6969, Host: 'localhost')
 server.own_app
