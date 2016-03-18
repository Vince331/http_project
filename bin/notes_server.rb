require './lib/notes/web'
server = Notes::Web.new(Port: 6969, Host: 'localhost')
server.own_app
