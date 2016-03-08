require 'rack'

# We know that this creates an object with a #call method.
# So a valid rack app is anything with a call method
# that can take the parsed web request as a hash named `env`,
# and return an array with the status, headers, and body lines.
app = Proc.new do |env|
  status  = 200
  headers = {'Content-Type' => 'text/html'}
  body    = '<form action="/lol-hello-thar" method="post" accept-charset="utf-8">'                              + "\n" +
              '<label for="this-be-the-data">Submit something:</label>'                                         + "\n" +
              '<input type="text/submit/hidden/button" name="this-be-the-data" value="" id="this-be-the-data">' + "\n" +
              '<p><input type="submit" value="Continue &rarr;"></p>'                                            + "\n" +
            '</form>'

  # Check out the local variable, `env`, that's what you need to parse the request to look like
  # Take the time to look at all the values and see how they came in from the request
  # Hypothesize about what they mean, etc.
  # Check out the unparsed request with `nc -l 4200`
  # Submit the form and figure out how that data becomes available to you
  require "pry"
  binding.pry

  headers['Content-Length'] = body.length.to_s
  [status, headers, body.lines]
end


Rack::Handler.default.run app, Port: 4300, Host: 'localhost'
