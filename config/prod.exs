use Mix.Config

config :web,
  ws_port: 4001,
  ws_host: {0, 0, 0, 0},
  tcp_port: 6666,
  tcp_acceptors_size: 100

config :maru, Web.Router,
  http: [port: 8080, ip: {0, 0, 0, 0}]

config :redis_poolex,
  reconnect: :no_reconnect,
  max_queue: :infinity,
  pool_size: 10,
  pool_max_overflow: 1,
  connection_string: "redis://127.0.0.1:6379/"

config :tirexs, :uri, "http://127.0.0.1:9200"
