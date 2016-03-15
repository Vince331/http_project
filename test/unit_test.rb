require 'notes/web' # <-- you'll need to make this
require 'net/http'  # this is from the stdlib
require 'stringio'

class ParsingTest < Minitest::Test
  #  def port
  #    9292
  #  end
  #
  #  def run_server(port, app, &block)
  #    server = Notes::Web.new(app, Port: port, Host: 'localhost')
  #    thread = Thread.new { server.start } # The thread allows the server to sit and wait for a request, but still return to here so we can send it.
  #    thread.abort_on_exception = true
  #    block.call
  #  ensure
  #    thread.kill if thread
  #    server.stop if server
  #  end

#  socket = StringIO.new "GET / HTTP/1.1\r\n" +
  #  #    "Host: localhost:3000\r\n" +

  #Connection: keep-alive\r\n" +

#  "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\n" +
  #  #    "Upgrade-Insecure-Requests: 1\r\n" +

  #User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36\r\n" +

#  "Accept-Encoding: gzip, deflate, sdch\r\n" +
  #  #    "Accept-Language: en-US,en;q=0.8\r\n" +

  #Cookie: gsScrollPos=\r\n" +

#  "\r\n"

  def test_it_parses_socket_input_in_a_predicatable_pattern
    socket = StringIO.new "GET / HTTP/1.1\r\n" +
      "Host: localhost:4300\r\n" +
      "Connection: keep-alive\r\n" +
      "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\n" +
      "Upgrade-Insecure-Requests: 1\r\n" +
      "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36\r\n" +
      "Accept-Encoding: gzip, deflate, sdch\r\n" +
      "Accept-Language: en-US,en;q=0.8\r\n" +
      "Cookie: gsScrollPos=\r\n" +
      "\r\n"

    env_hash = Notes::Web.parser(socket)

   # require "pry"
   # binding.pry
   # assert_equal 'localhost' , env_hash["SERVER_NAME"]
    assert_equal 'GET' , env_hash["REQUEST_METHOD"]
    assert_equal '/' , env_hash["PATH_INFO"]
    assert_equal 'HTTP/1.1' , env_hash["HTTP_VERSION"]

  end
  #  "SERVER_NAME"=>"localhost",
  # "REQUEST_METHOD"=>"GET",
  # "PATH_INFO"=>"/",
  # "HTTP_VERSION"=>"HTTP/1.1",
  # "HTTP_HOST"=>"localhost:4300",
  # "HTTP_CONNECTION"=>"keep-alive",
  # "HTTP_ACCEPT"=>"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
  # "HTTP_UPGRADE_INSECURE_REQUESTS"=>"1",

  # def test_1it_accepts_and_responds_to_a_web_request

  #   path_info = "this value should be overridden by the app!"

  #   app = Proc.new do |env_hash|
  #     path_info = env_hash['PATH_INFO']
  #     body      = "hello, class ^_^"
  #     [200, {'Content-Type' => 'text/plain', 'Content-Length' => body.length, 'omg' => 'bbq'}, [body]]
  #   end

  #   run_server port, app do
  #     response = Net::HTTP.get_response('localhost', '/path', port)
  #     assert_equal "200",              response.code
  #     assert_equal 'bbq',              response.header['omg']
  #     assert_equal "hello, class ^_^", response.body
  #   end
  # end

  # def test_it_repsonds_to_x
  #   my_path = "/foo"
  #   app = Proc.new do |env_hash|
  #    path_info = env_hash['PATH_INFO']
  #     body      = "hello"
  #     [200, {'Content-Type' => 'text/plain', 'Content-Length' => body.length, 'omg' => 'bbq'}, [body]]
  #   end

  #   run_server port, app do
  #     response = Net::HTTP.get_response('localhost', my_path, port)
  #     assert_equal "200",              response.code
  #    # assert_equal my_path,              response.body
  #     assert_equal "hello", response.body
  #   end
  # end

end
