defmodule Web.Tcp.ServerSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :tcp_server_supervisor)
  end

  def init(_) do
    children = [
      worker(Web.Tcp.Server, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

defmodule Web.Tcp.ClientSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :tcp_client_supervisor)
  end

  def start_client(token) do
    Supervisor.start_child(:tcp_client_supervisor, [token])
  end

  def init(_) do
    children = [
      worker(Web.Tcp.Client, [])
    ]

    # We also changed the `strategy` to `simple_one_for_one`.
    # With this strategy, we define just a "template" for a child,
    # no process is started during the Supervisor initialization, just
    # when we call `start_child/2`
    supervise(children, strategy: :simple_one_for_one)
  end
end

defmodule Web.Tcp.Server do
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

defmodule Web.Tcp.Client do
  require Logger
  require Poison

  alias Web.Pubsub

  def start_link(token) do
    GenServer.start_link(__MODULE__, token, name: String.to_atom(token))
  end

  def init(token) do
    Pubsub.subscribe("#{token}:vars:callback")
    {:ok, %{token: token}}
  end

  def handle_info(%{vars: vars}, %{token: token} = state) do
    Logger.debug("[tcp.sender] received message: #{inspect(vars)}")
    message = _pack(token, "vars", vars)
    Logger.debug("[tcp.sender] packed message: #{inspect(message)}")

    Logger.debug("[tcp.sender] begin send message: #{inspect(message)}")
    token |> _get_socket |> _send_back(message)
    Logger.debug("[tcp.sender] done send message: #{inspect(message)}")

    {:noreply, state}
  end

  def terminate(reason, status) do
    Logger.debug("[tcp.sender] reason: #{inspect(reason)}, status: #{inspect(status)}")
    :ok
  end

  def _send_back({socket, transport}, message) do
    Logger.debug("[tcp.sender] socket: #{inspect(socket)}, transport: #{inspect(transport)}, message: #{inspect(message)}")
    transport.send(socket, message)
  end

  def _pack(token, "vars", vars) do
    vars = vars
    |> Poison.encode!
    |> Base.encode64!

    "v:#{token}:vars"
  end

  defp _get_socket(token) do
    case Registry.lookup(Registry.Sockets, token) do
      [{_, value}] -> value
      _ -> Logger.error("[tcp.sender] no socket found in registry")
    end
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
        _register_socket(api_key, socket, transport)

        # TODO: register sender on callback from pubsub channel, don't need
        # to check if it registered or not but we should clean up it because of
        # limited resources.
        Web.Tcp.ClientSupervisor.start_client(api_key)

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

  def _register_socket(api_key, socket, transport) do
    case Registry.register(Registry.Sockets, api_key, {socket, transport}) do
      {:error, {:already_registered, _pid}} ->
        Registry.update_value(Registry.Sockets, api_key, fn (_) -> {socket, transport} end)
      {:error, reason} ->
        Logger.error(inspect(reason))
      _ ->
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
