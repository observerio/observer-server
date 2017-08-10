require 'socket'

TCP_PORT = 6667
KEY = 'testtesttest'

def socket_loop
  sock = TCPSocket.new('127.0.0.1', TCP_PORT)

  thread1 = Thread.new do
    while true
      sock.write("v:#{KEY}\n")
      sock.write("i:#{KEY}:W3sidmFsdWUiOiJleGFtcGxlIiwidHlwZSI6InN0cmluZyIsIm5hbWUiOiJ0ZXN0aW5nMSJ9LHsidmFsdWUiOiItMSIsInR5cGUiOiJpbnRlZ2VyIiwibmFtZSI6InRlc3RpbmcyIn1d\n")
      sock.write("l:#{KEY}:W3sidGltZXN0YW1wIjoxMjMxMjMxMjMsIm1lc3NhZ2UiOiJ0ZXN0aW5nMSJ9LHsidGltZXN0YW1wIjoxMjMxMjMxMjMsIm1lc3NhZ2UiOiJ0ZXN0aW5nMiJ9XQ==\n")
      sleep 5
    end
  end

  thread2 = Thread.new do
    while line = sock.gets
      puts(line)
    end
  end

  thread1.join
  thread2.join
rescue => e
  puts e.inspect
  socket_loop
end

socket_loop
