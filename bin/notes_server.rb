require './lib/notes/server'
server = Notes::Server.new(Port: 6969, Host: 'localhost')
server.own_app
