defmodule Web.Tcp do
  @port 6667
  @acceptors_size 100

  def start_link do
    opts = [port: @port]
    {:ok, _} = :ranch.start_listener(:tcp, @acceptors_size, :ranch_tcp, opts, Web.Tcp.Handler, [])
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
          {:reply, message} -> transport.send(socket, message)
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

  alias Web.Gateway

  @moduledoc """
    Server messages:

      - `l:api_key:logs`
        logs - should come as json array and encoded base64

      - `i:api_key:vars`
        vars - should come as json dictionary and encoded by base64

      - `v:api_key`
        api_key - should verify key using our registry

    Client messages:
      - `i:s:name:value` - var set by name value inside of app
  """
  def process("l:" <> <<api_key :: size(64) >> <> ":" <> logs) do
    Logger.debug("[protocol] api_key: #{inspect(api_key)}, logs: #{inspect(logs)}")
    Gateway.logs(api_key, logs)
    :ok
  end

  def process("i:" <> <<api_key :: size(64) >> <> ":" <> vars) do
    Logger.debug("[protocol] api_key: #{inspect(api_key)}, vars: #{inspect(vars)}")
    Gateway.vars(api_key, vars)
    :ok
  end

  def process("v:" <> <<api_key :: size(64)>>) do
    # search inside of database mention for api_key
    {:reply, "OK"}
  end

  def process(_), do: :error
end
