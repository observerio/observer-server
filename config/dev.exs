use Mix.Config

config :web, :tcp_port, 6667
config :web, :web_port, 8080
config :web, :acceptors_size, 100

config :redis_poolex,
  reconnect: :no_reconnect,
  max_queue: :infinity,
  pool_size: 10,
  pool_max_overflow: 1,
  connection_string: "redis://127.0.0.1:6379/"

config :tirexs, :uri, "http://127.0.0.1:9200"
