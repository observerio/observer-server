use Mix.Config

config :web, :ws_port, 4000

config :web, :tcp_port, 6667
config :web, :tcp_acceptors_size, 100

config :maru, Web.Router,
  http: [port: 8080]

config :redis_poolex,
  reconnect: :no_reconnect,
  max_queue: :infinity,
  pool_size: 10,
  pool_max_overflow: 1,
  connection_string: "redis://observer_redis:6379/"

config :tirexs, :uri, "http://observer_elasticsearch:9200"
