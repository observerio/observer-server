defmodule Web.Gateway do
  # TODO: should receive message from tcp listeners
  #
  # - storage:
  #   - store variables
  #
  # - web:
  #   - should notify listeners about changed data there and we should
  #   update client UI
  #

  import Tirexs.Bulk

  require Logger

  def logs(logs, api_key) do
    data = logs |> Enum.map(&Map.to_list(&1))

    payload = bulk do
      index [index: "logs-#{api_key}", type: "Log"], data
    end

    {:ok, 200, response} = Tirexs.bump!(payload)._bulk()

    Logger.debug("[gateway] elastic response: #{inspect(response)}")

    :ok
  end

  def vars(vars, api_key) do
  end
end
