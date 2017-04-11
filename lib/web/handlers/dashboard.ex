defmodule Web.Handlers.Dashboard do
  @behaviour :cowboy_websocket_handler

  alias Web.Pubsub

  require Logger
  require Poison

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @timeout 60000 # terminate if no activity for one minute

  #Called on websocket connection initialization.
  def websocket_init(_type, req, _opts) do
    state = %{}
    {:ok, req, state, @timeout}
  end

  @doc """
  gproc should send here message on push update
  """
  def websocket_info(args, req, state) do
    {:reply, {:text, inspect(args)}, req, state}
  end

  # Handle 'ping' messages from the browser - reply
  def websocket_handle({:text, "ping"}, req, state) do
    {:reply, {:text, "pong"}, req, state}
  end

  # Handle other messages from the browser - don't reply
  def websocket_handle({:text, data}, req, state) do
    event = data |> Poison.decode!

    Logger.debug("[websocket_handle] #{inspect(event)}")

    # don't subscribe if we have it
    Pubsub.subscribe("#{event["data"]["key"]}:vars")
    Pubsub.subscribe("#{event["data"]["key"]}:logs")

    {:ok, req, state}
  end

  # No matter why we terminate, remove all of this pids subscriptions
  def websocket_terminate(_reason, _req, _state) do
    :ok
  end
end
