defmodule Web.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Plug.Adapters.Cowboy

  def _ws_port, do: String.to_integer(Application.get_env(:web, :ws_port))
  def _ws_host, do: Application.get_env(:web, :ws_host)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Web.Worker.start_link(arg1, arg2, arg3)
      supervisor(Web.Tcp.ServerSupervisor, []),
      supervisor(Web.Tcp.ClientSupervisor, []),
      supervisor(Registry, [:unique, Registry.Sockets]),
      Cowboy.child_spec(:http, __MODULE__, [], [
        ip: _ws_host(), port: _ws_port(), dispatch: dispatch])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Web.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_, [
          {"/ws", Web.Handlers.Dashboard, []},
        ]}
    ]
  end
end
