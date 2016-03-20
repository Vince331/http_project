require 'socket'
require 'notes/parser'

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
