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
    {:ok, %{token: token, messages: []}}
  end

  def handle_info(%{vars: vars}, %{token: token, messages: messages} = state) do
    Logger.debug("[tcp.client] received message: #{inspect(vars)}")
    message = _pack(token, "vars", vars)
    Logger.debug("[tcp.client] packed message: #{inspect(message)}")

    messages = messages ++ [message]

    # TODO: Don't store more than 100 items in queue for now, don't know behaviuor
    # for future
    if Enum.count(messages) > 100 do
      messages = Enum.slice(messages, -100..-1)
    end

    Logger.debug("[tcp.client] begin send message: #{inspect(messages)}")
    state = token |> _get_socket |> _send_back(messages, state)
    Logger.debug("[tcp.client] done send message: #{inspect(messages)}")

    Logger.debug("[tcp.client] messages: #{inspect(messages)}")

    {:noreply, state}
  end

  def terminate(reason, status) do
    Logger.debug("[tcp.client] reason: #{inspect(reason)}, status: #{inspect(status)}")
    :ok
  end

  defp _send_back({:ok, socket}, messages, state) do
    :ok = _send(socket, messages)
    %{state | messages: []}
  end
  defp _send_back(:enqueue, messages, state) do
    %{state | messages: messages}
  end

  defp _send(s, []), do: :ok
  defp _send({socket, transport} = s, [message | messages]) do
    transport.send(socket, message)
    _send(s, messages)
  end

  def _pack(token, "vars", vars) do
    vars = vars
    |> Poison.encode!
    |> Base.encode64

    "v:#{token}:#{vars}\n"
  end

  defp _get_socket(token) do
    Logger.debug("[tcp.socket] search for socket, transport by token: #{inspect(token)}")
    response = case Registry.lookup(Registry.Sockets, token) do
      [{_, socket}] -> {:ok, socket}
      [] -> :enqueue
    end
    Logger.debug("[tcp.client] _get_socket: #{inspect(response)}")
    response
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

    case transport.peername(socket) do
      {:ok, _peer} -> loop(socket, transport, "")
      {:error, reason} -> Logger.error("[tcp.handler] init receive error reason: #{inspect(reason)}")
    end
  end

  @timeout 5_000

  def loop(socket, transport, acc) do
    # Don't flood messages of transport, receive once and leave the remaining
    # data in socket until we run recv again.
    transport.setopts(socket, [active: :once])

    # before to proceed with receive block on messages we should call
    # once transport.messages() to ping ranch
    {ok, closed, error} = transport.messages()

    receive do
      {ok, socket, data} ->
        Logger.info("[tcp.handler] received data: #{inspect(data)}")

        acc <> data
        |> String.split("\n")
        |> Enum.map(&(String.trim(&1)))
        |> _process(socket, transport)

        loop(socket, transport, "")
      {closed, socket} ->
        Logger.debug("[tcp.handler] closed socket: #{inspect(socket)}")
      {error, socket, reason} ->
        Logger.error("[tcp.handler] socket: #{inspect(socket)}, closed becaose of the error reason: #{inspect(reason)}")
      {:error, error} ->
        Logger.error("[tcp.handler] error: #{inspect(error)}")
      {'EXIT', parent, reason} ->
        Logger.error("[tcp.handler] exit parent reason: #{inspect(reason)}")
        Process.exit(self(), :kill)
      message ->
        Logger.debug("[tcp.handler] message on receive block: #{inspect(message)}")
    after @timeout ->
      Logger.debug("[tcp.handler] received timeout on processing messages from transport")
      loop(socket, transport, acc)
    end
  end

  defp _kill(), do: Process.exit(self(), :kill)

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

        Logger.debug("[tcp.server] transport should respond with OK")

        case transport.send(socket, "OK\n") do
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
    Logger.debug("[tcp.handler] _register_socket token: #{api_key}")

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
  def process("l:" <> <<api_key :: bytes-size(12)>> <> ":" <> logs) do
    Logger.debug("[protocol] api_key: #{api_key}, logs: #{inspect(logs)}")
    logs
    |> Base.decode64!
    |> Poison.decode!
    |> Gateway.logs(api_key)
  end

  def process("i:" <> <<api_key :: bytes-size(12)>> <> ":" <> vars) do
    Logger.debug("[protocol] api_key: #{api_key}, vars: #{inspect(vars)}")
    vars
    |> Base.decode64!
    |> Poison.decode!
    |> Gateway.vars(api_key)
  end

  def process("v:" <> <<api_key :: bytes-size(12)>>) do
    if Users.verify_key(api_key) do
      {:verified, api_key}
    else
      {:error, "not registered user with api_key: #{api_key}"}
    end
  end

  def process(_), do: :error
end
