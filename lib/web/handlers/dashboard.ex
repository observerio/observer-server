defmodule Web.Handlers.Dashboard do
  @behaviour :cowboy_websocket_handler

  alias Web.Pubsub

  require Logger
  require Poison

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @timeout 60_000 # terminate if no activity for one minute

  #Called on websocket connection initialization.
  def websocket_init(_type, req, _opts) do
    state = %{keys: []}
    {:ok, req, state, @timeout}
  end

  @doc """
  gproc should send here message on push update
  """
  def websocket_info(args, req, state) do
    {:reply, {:text, Poison.encode!(args)}, req, state}
  end

  # Handle other messages from the browser - don't reply
  def websocket_handle({:text, data}, req, state) do
    Logger.info("MESSAGE: #{inspect(data)}")
    data |> Poison.decode! |> _process(req, state)
  end

  # No matter why we terminate, remove all of this pids subscriptions
  def websocket_terminate(_reason, _req, state) do
    Logger.info(inspect(state))
    :ok
  end

  defp _process(%{"event" => "vars", "data" => %{"token" => token, "vars" => vars}, req, state) do
    Logger.info("VARS DATA: #{inspect(vars)}")

    Pubsub.publish("#{token}:vars:callback", %{vars: vars})

    {:ok, req, state}
  end

  defp _process(%{"event" => "init", "data" => %{"token" => token}}, req, state) do
    Pubsub.subscribe("#{token}:vars")
    Pubsub.subscribe("#{token}:logs")

    state = %{keys: state[:keys] ++ token}

    {:ok, req, state}
  end
end
