defmodule Web.Tcp do
  require Logger

  def start_link do
    Logger.info("[tcp] starting server on port :#{_port()}")
    opts = [port: _port()]
    {:ok, _} = :ranch.start_listener(:tcp, _acceptors_size(), :ranch_tcp,
                                     opts, Web.Tcp.Handler, [])
  end

  def _port do
    Application.get_env(:web, :port)
  end

  def _acceptors_size do
    Application.get_env(:web, :acceptors_size)
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
        case data |> String.strip |> Web.Tcp.Protocol.process do
          {:reg, api_key} ->
            case Registry.register(Registry.Sockets, api_key, socket) do
              {:error, {:already_registered, _pid}} ->
                Registry.update_value(Registry.Sockets, api_key, fn (_) -> socket end)
              {:error, reason} -> Logger.error(inspect(reason))
              _ ->
            end

            case transport.send(socket, "OK") do
              {:error, reason} -> Logger.error(inspect(reason))
              _ ->
            end
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
  require Poison

  alias Web.Gateway

  @moduledoc """
    Server messages:

      - `l:logs`
        logs - should come as json array and encoded base64

      - `i:vars`
        vars - should come as json dictionary and encoded by base64

      - `v:api_key`
        api_key - should verify key using our registry

    Client messages:
      - `i:s:name:value` - var set by name value inside of app
  """
  def process("l:" <> <<api_key :: bytes-size(8)>> <> ":" <> logs) do
    Logger.debug("[protocol] api_key: #{inspect(api_key)}, logs: #{inspect(logs)}")
    logs
    |> Base.decode64!
    |> Poison.decode!
    |> Gateway.logs(api_key)
    :ok
  end

  def process("i:" <> <<api_key :: bytes-size(8)>> <> ":" <> vars) do
    Logger.debug("[protocol] api_key: #{inspect(api_key)}, vars: #{inspect(vars)}")
    vars
    |> Base.decode64!
    |> Poison.decode!
    |> Gateway.vars(api_key)
    :ok
  end

  def process("v:" <> <<api_key :: bytes-size(8)>>) do
    # search inside of database mention for api_key
    # REGISTER socket in registory by api_key
    Logger.debug("[protocol] api_key: #{inspect(api_key)}")
    case Users.verify_key(api_key) do
      {:error, _reason} = error -> error
      :ok -> {:reg, api_key}
    end
  end

  def process(_), do: :error
end
