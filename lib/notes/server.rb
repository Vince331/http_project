require 'socket'

class Notes
  class Server
    formpath = File.realdirpath("views/root.html")
    notepath = File.realdirpath("views/notes.rb")
    FORM = File.read(formpath)
    NOTES = File.read(notepath)

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
        Notes::Server.printer(socket, response_code, headers, body)
      end
    end

    def self.printer(socket, response_code, headers, body)
      socket.print "HTTP/1.1 " + response_code.to_s + "\r\n"
      socket.print headers.map { |k, v| "#{k}: #{v}" }.join("\r\n") + "\r\n\r\n"
      socket.print body.join
      socket.close
    end

    def self.get_request(socket)
      final = []
      final << socket.gets
      final << socket.gets while final[-1] != "\r\n"
      final
    end

    def self.request_line(final)
      first_line = final.shift
      first_line = first_line.split(" ")
      check = {  "REQUEST_METHOD" => first_line[0], "PATH_INFO" => first_line[1],
                 "SERVER_PROTOCOL" => first_line[2], "HTTP_VERSION" => first_line[2]
              }
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
      if !query_string.empty?
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
