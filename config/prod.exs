use Mix.Config

config :web,
  ws_port: System.get_env("WS_PORT") || "${WS_PORT}",
  ws_host: {0, 0, 0, 0},
  tcp_port: System.get_env("TCP_PORT") || "${TCP_PORT}",
  tcp_acceptors_size: System.get_env("TCP_ACCEPTORS_SIZE") || "${TCP_ACCEPTORS_SIZE}"

config :maru, Web.Router,
  http: [
    port: System.get_env("WEB_PORT") || "${WEB_PORT}",
    ip: {0, 0, 0, 0}
  ]

config :redis_poolex,
  reconnect: :no_reconnect,
  max_queue: :infinity,
  pool_size: 10,
  pool_max_overflow: 1,
  connection_string: System.get_env("REDIS_CONNECTION_STRING") || "${REDIS_CONNECTION_STRING}"

config :tirexs, :uri, System.get_env("ES_URI") || "${ES_URI}"
