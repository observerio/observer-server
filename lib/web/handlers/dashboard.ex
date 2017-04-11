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

  # Handle other messages from the browser - don't reply
  def websocket_handle({:text, data}, req, state) do
    data |> Poison.decode! |> _process(req, state)
  end

  # No matter why we terminate, remove all of this pids subscriptions
  def websocket_terminate(_reason, _req, _state) do
    :ok
  end

  defp _process(%{"event" => "init", "data" => %{"key" => key}}, req, state) do
    Pubsub.subscribe("#{key}:vars")
    Pubsub.subscribe("#{key}:logs")

    {:ok, req, state}
  end

end
