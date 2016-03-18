require 'rack'

app = Proc.new do |env|
  form = "<form action='/search' method='GET'>
          <input type='text' name='query'>
          <input type='Submit'>
          </form>"

  [ 200, { 'Content-Type' => 'text/html', 'Content-Length' => form.length.to_s }, form.lines ]
end

Rack::Handler.default.run app, Port: 4300, Host: 'localhost'
