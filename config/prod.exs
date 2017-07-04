use Mix.Config

config :web,
  ws_port: {:system, "WS_PORT"},
  ws_host: {0, 0, 0, 0},
  tcp_port: {:system, "TCP_PORT"},
  tcp_acceptors_size: {:system, "TCP_ACCEPTORS_SIZE"}

config :maru, Web.Router,
  http: [port: {:system, "WEB_PORT"}, ip: {0, 0, 0, 0}]

config :redis_poolex,
  reconnect: :no_reconnect,
  max_queue: :infinity,
  pool_size: 10,
  pool_max_overflow: 1,
  connection_string: "${REDIS_CONNECTION_STRING}"

config :tirexs, :uri, "${ES_URI}"
