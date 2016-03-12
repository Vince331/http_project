require 'rack'
require 'socket'

server = TCPServer.new "localhost" , 9293

socket = server.accept

socket.print "HTTP/1.1 200 Moved Permanently\r\n"
socket.print "Content-Type: text/html\r\n"
socket.print "Content-Length: 5\r\n"
socket.print "omg: hi\r\n"
socket.print "\r\n"
socket.print "hello"

socket.close
server.close
