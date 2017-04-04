defmodule Web.TcpTest do
  use ExUnit.Case
  doctest Web.Tcp

  require Logger

  test "should register user session" do
    port = Application.get_env(:web, :port)
    host = "127.0.0.1" |> String.to_char_list
    api_key = "12345678"

    {:ok, socket} = :gen_tcp.connect(host, port, [])
    :ok = :gen_tcp.send(socket, "v:" <> api_key)

    {:ok, reply} = :gen_tcp.recv(socket, 0, 5000)
    assert reply == "OK"
  end
end
