require 'socket'

server = TCPServer.new "localhost" , 9293

socket = server.accept

socket.print "HTTP/1.1 200 hellllllllllllllllllllllo\r\n"
socket.print "Content-Type: text/html\r\n"
socket.print "Content-Length: 125\r\n"
socket.print "\r\n"
socket.print "<form action='/search' method='post'>
               <input type='textarea' name = 'query'></input>
               <input type='Submit'></input>
               </form>"

               require "pry"
               binding.pry
# socket.close
# server.close
