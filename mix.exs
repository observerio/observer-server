defmodule Web.Mixfile do
  use Mix.Project

  def project do
    [app: :web,
     version: "0.0.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {Web.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ranch, "~> 1.3"},
      {:gproc, "~> 0.6.1"},
      {:web_socket, "~> 0.1.0"},
      {:poison, "~> 3.0"},
      {:tirexs, "~> 0.8"},
      {:secure_random, "~> 0.5"},
      {:comeonin, "~> 3.0"},
      {:maru, "~> 0.11"},
      {:redis_poolex, github: "oivoodoo/redis_poolex"},
      {:credo, "~> 0.7", only: [:dev, :test]},
      {:dogma, "~> 0.1", only: [:dev, :test]},
      {:cors_plug, "~> 1.2"},
      {:mix_docker, "~> 0.5.0"}
    ]
  end
end
