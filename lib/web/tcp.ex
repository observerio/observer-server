defmodule Web.Tcp do
  @port 6667
  def start_link do
    opts = [port: @port]
    {:ok, _} = :ranch.start_listener(:tcp, 100, :ranch_tcp, opts, Web.Tcp.Handler, [])
  end
end

defmodule Web.Tcp.Handler do
  require Logger

  @moduledoc """
  """

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
        case data |> String.strip |> Web.Tcp.Protocol.process do
          :error -> Logger.error("error on processing: #{inspect(data)}")
          _ ->
        end
        loop(socket, transport)
      _ ->
        :ok = transport.close(socket)
    end
  end
end

defmodule Web.Tcp.Protocol do
  require Logger

  @moduledoc """
    Server messages:

      - `l:api_key:logs`
        logs - should come as json array and encoded base64

      - `i:api_key:vars`
        vars - should come as json dictionary and encoded by base64

    Client messages:
  `
  """
  def process("l:" <> <<api_key :: size(64) >> <> ":" <> logs) do
    Logger.info("api_key: #{inspect(api_key)}, logs: #{inspect(logs)}")
    :ok
  end

  def process(_), do: :error
end
