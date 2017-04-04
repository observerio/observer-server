defmodule Web.Gateway do
  # TODO: should receive message from tcp listeners
  #
  # - storage:
  #   - store logs
  #   - store variables
  #
  # - web:
  #   - should notify listeners about changed data there and we should
  #   update client UI
  #

  import Tirexs.Bulk

  require Logger

  def logs(logs, api_key) do
    payload = bulk([index: "logs-#{api_key}", type: "Log"]) do
      index [logs]
    end

    Tirexs.bump!(payload)._bulk()
  end
end
