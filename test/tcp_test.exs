defmodule Web.TcpTest do
  use ExUnit.Case
  doctest Web.Tcp

  require Logger

  setup do
    port = Application.get_env(:web, :port)
    host = "127.0.0.1" |> String.to_char_list

    {:ok, socket} = :gen_tcp.connect(host, port, [active: false])
    {:ok, socket: socket, api_key: "12345678"}
  end

  test "should register user session", %{socket: socket, api_key: api_key} do
    :ok = :gen_tcp.send(socket, "v:" <> api_key)
    {:ok, reply} = :gen_tcp.recv(socket, 0, 1000)
    assert reply == 'OK'
  end
end
