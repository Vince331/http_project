require 'socket'

class Notes
  class Server
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

    def initialize(hash, app = nil)
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
        env = Server.parser(socket)
        response_code, headers, body = @app.call(env)
        header = "HTTP/1.1 " + response_code.to_s + " OK\r\n" +
          headers.map { |k, v| "#{k}: #{v}\r\n" }.join
        socket.print header
        socket.print "\r\n"
        socket.print body.join
        socket.close
      end
    end


    def self.get_request(socket)
      final = []
      final << socket.gets
      while final[-1] != "\r\n"
        final << socket.gets
      end
      final
    end

    def self.request_line(final)
      first_line = final.shift
      first_line = first_line.split(" ")
      check = {  "REQUEST_METHOD" => first_line[0],
                 "PATH_INFO"      => first_line[1],
                 "SERVER_PROTOCOL"=> first_line[2],
                 "HTTP_VERSION"   => first_line[2] }
      check
    end

    def self.query_string(check)
      if check["PATH_INFO"].include?("?")
        query = check["PATH_INFO"][/=.*/][1..-1].split("+")
        check["QUERY_STRING"] = query
      else
        check["QUERY_STRING"] = ""
      end
      check["QUERY_STRING"]
    end

    def self.notes_check(query_string)
      if query_string.length > 0
        result = NOTES
        query_string.select do |elem|
          result = result.select do |x|
            x.upcase.include? elem.upcase
          end
        end
        @form = result.join("<br>")
      else
        @form = FORM
      end
    end

    def self.to_hash(final)
      array = final.map do |x|
        x.chomp.split(": ", 2)
      end
      # a method to append neccesary to make the http request work
      append(array)
    end

    def self.append(array)
      i = 0
      env = {}
      array.each do |x|
        x[0] = "HTTP_#{x[0]}" unless x[0] == 'CONTENT_TYPE' || x[0] == 'CONTENT_LENGTH'
        env[x[0].upcase.tr("-", "_")] = x[1] unless x[0].nil?
      end
      env
    end

    def self.parser(socket)
      # takes in request and returns it as an array named final
      final = get_request(socket)
      # takes first line from final and turns it into an http request line
      check = request_line(final)
      # if a search has occured it returns an array of the query
      check["QUERY_STRING"] = query_string(check)
      # using that query array it returns notes that match the query
      notes_check(check["QUERY_STRING"])
      # turns the request into a hash that the server can respond with
      env = to_hash(final)
      # returns the full hash of the request that the server can respond with
      check.merge(env)
    end

    def own_app
      loop do
        socket = @server.accept
        parser(socket)
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
