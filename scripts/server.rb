require 'socket'

TCP_PORT = 6667
KEY = 'testtesttest'

sock = TCPSocket.new('127.0.0.1', TCP_PORT)

while true
  sock.write("v:#{KEY}\n")
  sock.write("i:#{KEY}:W3sidmFsdWUiOiJleGFtcGxlIiwidHlwZSI6InN0cmluZyIsIm5hbWUiOiJ0ZXN0aW5nMSJ9LHsidmFsdWUiOiItMSIsInR5cGUiOiJpbnRlZ2VyIiwibmFtZSI6InRlc3RpbmcyIn1d\n")
  sock.write("l:#{KEY}:W3sidGltZXN0YW1wIjoxMjMxMjMxMjMsIm1lc3NhZ2UiOiJ0ZXN0aW5nMSJ9LHsidGltZXN0YW1wIjoxMjMxMjMxMjMsIm1lc3NhZ2UiOiJ0ZXN0aW5nMiJ9XQ==\n")
  sleep 2
  puts(sock.read)
  sleep 5
end

sock.close
