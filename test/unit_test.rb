require 'notes/server' # <-- you'll need to make this
require 'net/http' # this is from the stdlib

class ParsingTest < Minitest::Test
  def test_it_returns_the_path_info_correctly
    socket = StringIO.new ["GET /search&query=add+1 HTTP/1.1\r\n",
      "Host: localhost:4300\r\n",
      "Connection: keep-alive\r\n",
      "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\n",
      "Upgrade-Insecure-Requests: 1\r\n",
      "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3)\
      AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36\r\n",
      "Accept-Encoding: gzip, deflate, sdch\r\n",
      "Accept-Language: en-US,en;q=0.8\r\n",
      "Cookie: gsScrollPos=\r\n\r\n"].join
    env_hash = Notes::Server.parser(socket)
    assert_equal 'GET', env_hash["REQUEST_METHOD"]
    assert_equal '/search&query=add+1', env_hash["PATH_INFO"]
    assert_equal 'HTTP/1.1', env_hash["HTTP_VERSION"]
  end

  def test_it_returns_the_path_ifo_with_the_search_correct
    socket = StringIO.new ["GET / HTTP/1.1\r\n",
      "Host: localhost:4300\r\n", "Connection: keep-alive\r\n",
      "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\n",
      "Upgrade-Insecure-Requests: 1\r\n",
      "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 \
      (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36\r\n",
      "Accept-Encoding: gzip, deflate, sdch\r\n",
      "Accept-Language: en-US,en;q=0.8\r\n", "Cookie: gsScrollPos=\r\n\r\n"].join
    env_hash = Notes::Server.parser(socket)
    assert_equal 'GET', env_hash["REQUEST_METHOD"]
    assert_equal '/', env_hash["PATH_INFO"]
    assert_equal 'HTTP/1.1', env_hash["HTTP_VERSION"]
  end
end
