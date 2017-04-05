defmodule Web.TcpTest do
  use ExUnit.Case
  doctest Web.Tcp

  alias Web.Db.Users

  require RedisPoolex
  require Logger
  require Poison
  require Tirexs.Query

  setup do
    RedisPoolex.query(["FLUSHDB"])

    {:ok, api_key} = Users.register(%{email: "user1@example.com", password: "12345678"})

    port = Application.get_env(:web, :port)
    host = "127.0.0.1" |> String.to_char_list

    {:ok, socket} = :gen_tcp.connect(host, port, [active: false])
    {:ok, socket: socket, api_key: api_key}
  end

  test "should register user session", %{socket: socket, api_key: api_key} do
    :ok = :gen_tcp.send(socket, "v:" <> api_key)
    {:ok, reply} = :gen_tcp.recv(socket, 0, 1000)
    assert reply == 'OK'
  end

  test "should bulk insert logs on tcp request", %{socket: socket, api_key: api_key} do
    :ok = :gen_tcp.send(socket, "v:" <> api_key)
    :ok = :gen_tcp.send(socket, "l:" <> api_key <> ":" <> ([%{message: "testing1", timestamp: 123123123}, %{message: "testing2", timestamp: 123123123}] |> Poison.encode! |> Base.encode64))

    :timer.sleep(2000)

    assert {:ok, 200, %{hits: %{hits: hits}} = response} = Tirexs.Query.create_resource([index: "logs-#{api_key}", search: ""])
    assert Enum.count(hits) == 2
  end
end
