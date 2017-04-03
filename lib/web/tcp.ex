defmodule Web.Tcp do
  @port 6667
  def start_link do
    opts = [port: @port]
    {:ok, _} = :ranch.start_listener(:tcp, 100, :ranch_tcp, opts, Web.Tcp.Handler, [])
  end
end

defmodule Web.Tcp.Handler do
  require Logger

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, _Opts = []) do
    :ok = :ranch.accept_ack(ref)
    loop(socket, transport)
  end

  def loop(socket, transport) do
    case transport.recv(socket, 0, 5000) do
      {:ok, data} ->
        transport.send(socket, data)
        loop(socket, transport)
      _ ->
        :ok = transport.close(socket)
    end
  end
end
