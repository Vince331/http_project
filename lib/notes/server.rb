require 'socket'

class Notes
  class Server
    attr_accessor :server

    def initialize(hash, app = nil)
      @server = TCPServer.new hash[:Host], hash[:Port]
      @app =  app
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


    def self.parser(socket)
      Parser.new(socket).call
    end
    class Parser
      def initialize(socket)
        @socket = socket
      end

      def call
      # takes in request and returns it as an array named final
      final = get_request(@socket)
      # takes first line from final and turns it into an http request line
      check = request_line(final)
      # if a search has occured it returns an array of the query
      check["QUERY_STRING"] = query_string(check)
      # turns the request into a hash that the server can respond with
      env = to_hash(final)
      # returns the full hash of the request that the server can respond with
      check.merge(env)
      end

    def get_request(socket)
      final = []
      final << socket.gets
      final << socket.gets while final[-1] != "\r\n"
      final
    end

    def request_line(final)
      first_line = final.shift
      first_line = first_line.split(" ")
      check = {  "REQUEST_METHOD" => first_line[0], "PATH_INFO" => first_line[1],
                 "SERVER_PROTOCOL" => first_line[2], "HTTP_VERSION" => first_line[2]
      }
      check
    end

    def query_string(check)
      if check["PATH_INFO"].include?("?")
        query = check["PATH_INFO"][/=.*/][1..-1].split("+")
        check["QUERY_STRING"] = query
      else
        check["QUERY_STRING"] = ""
      end
      check["QUERY_STRING"]
    end

    def to_hash(final)
      array = final.map do |x|
        x.chomp.split(": ", 2)
      end
      # a method to append neccesary to make the http request work
      append(array)
    end

    def append(array)
      env = {}
      array.each do |x|
        x[0] = "HTTP_#{x[0]}" unless x[0] == 'CONTENT_TYPE' || x[0] == 'CONTENT_LENGTH'
        env[x[0].upcase.tr("-", "_")] = x[1] unless x[0].nil?
      end
      env
    end



    end
  end

  formpath = File.realdirpath("views/root.html")
  FORM = File.read(formpath)
  notepath = File.realdirpath("views/notes.rb")
  NOTES = eval File.read(notepath)
  APP = Proc.new do |env|
    form = FORM
    # using that query array it returns notes that match the query
    query_string = env["QUERY_STRING"]
    if !query_string.empty?
      result = NOTES
      query_string.select do |elem|
        result = result.select do |x|
          x.upcase.include? elem.upcase
        end
      end
      form = result.join("<br>")
    else
      form = FORM
    end
    response_code = 200
    headers = {
      "Content-Type" => "text/html", "Content-Length" => form.length
    }
    body = [form]
    [response_code, headers, body]
  end
end
