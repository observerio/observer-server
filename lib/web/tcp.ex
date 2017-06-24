defmodule Web.Tcp do
  require Logger

  def start_link do
    Logger.info("[tcp] starting server on port :#{_port()}")
    opts = [port: _port()]
    {:ok, _} = :ranch.start_listener(:tcp, _acceptors_size(), :ranch_tcp,
                                     opts, Web.Tcp.Handler, [])
  end

  def _port do
    Application.get_env(:web, :tcp_port)
  end

  def _acceptors_size do
    Application.get_env(:web, :tcp_acceptors_size)
  end
end

defmodule Web.Tcp.Handler do
  require Logger

  alias Web.Pubsub

  @moduledoc """
  `Handler` is wainting lines separated by \n new line, in case if handler don't
  see new line it starts to accumulate data until it receives new line.

  `Registry.Sockets` contains api_key -> socket records for easy back communication
  from dashboard page to tcp clients.
  """

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def handle_info(msg, state) do
    Logger.info("TCP SERVER RECEIVED MESSAGE FROM SOCKET: #{inspect(msg)}")
    {:noreply, state}
  end

  def init(ref, socket, transport, _opts = []) do
    :ok = :ranch.accept_ack(ref)
    loop(socket, transport, "")
  end

  def loop(socket, transport, acc) do
    case transport.recv(socket, 0, 5000) do
      {:ok, data} ->
        Logger.info("TCP data: #{inspect(data)}")

        acc <> data
        |> String.split("\n")
        |> Enum.map(&(String.trim(&1)))
        |> _process(socket, transport)
      _ ->
        :ok = transport.close(socket)
    end
  end

  defp _process([], socket, transport), do: loop(socket, transport, "")
  defp _process([""], socket, transport), do: loop(socket, transport, "")
  defp _process([line, ""], socket, transport) do
    _protocol(line, socket, transport)
    loop(socket, transport, "")
  end
  defp _process([line], socket, transport), do: loop(socket, transport, line)
  defp _process([line | lines], socket, transport) do
    _protocol(line, socket, transport)
    _process(lines, socket, transport)
  end

  defp _protocol(line, socket, transport) do
    Logger.debug("[_protocol] line: #{line}")

    case line |> Web.Tcp.Protocol.process do
      {:verified, api_key} ->
        _register_socket(api_key, socket)

        case transport.send(socket, "OK") do
          {:error, reason} ->
            Logger.error(inspect(reason))
          _ ->
        end
      {:error, reason} ->
        Logger.error("[tcp] #{inspect(reason)}")
      :error ->
        Logger.error("error on processing: #{inspect(line)}")
      _ ->
    end
  end

  def _register_socket(api_key, socket) do
    case Registry.register(Registry.Sockets, api_key, socket) do
      {:error, {:already_registered, _pid}} ->
        Registry.update_value(Registry.Sockets, api_key, fn (_) -> socket end)
      {:error, reason} ->
        Logger.error(inspect(reason))
      _ ->
        Pubsub.subscribe("#{api_key}:vars:callback")
    end
  end
end

defmodule Web.Tcp.Protocol do
  require Logger
  require Poison

  alias Web.Gateway
  alias Web.Db.Users

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
  def process("l:" <> <<api_key :: bytes-size(12)>> <> ":" <> logs = line) do
    Logger.debug("[protocol] api_key: #{inspect(api_key)}, logs: #{inspect(logs)}")
    logs
    |> Base.decode64!
    |> Poison.decode!
    |> Gateway.logs(api_key)
  end

  def process("i:" <> <<api_key :: bytes-size(12)>> <> ":" <> vars = line) do
    Logger.debug("[protocol] api_key: #{inspect(api_key)}, vars: #{inspect(vars)}")
    vars
    |> Base.decode64!
    |> Poison.decode!
    |> Gateway.vars(api_key)
  end

  def process("v:" <> <<api_key :: bytes-size(12)>> = line) do
    if Users.verify_key(api_key) do
      {:verified, api_key}
    else
      {:error, "not registered user with api_key: #{inspect(api_key)}"}
    end
  end

  def process(_), do: :error
end
