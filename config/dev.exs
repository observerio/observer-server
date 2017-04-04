use Mix.Config

config :web, :port, 6667
config :web, :acceptors_size, 100

config :redis_poolex,
  reconnect: :no_reconnect,
  max_queue: :infinity,
  pool_size: 10,
  pool_max_overflow: 1,
  connection_string: "redis://127.0.0.1:6379/"