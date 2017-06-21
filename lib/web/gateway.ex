defmodule Web.Gateway do
  import Tirexs.Bulk

  require Logger

  alias RedisPoolex, as: Redis
  alias Web.Pubsub

  @doc """
  Store logs in Elasticsearch server and notify subscribers about the updates
  """
  def logs(logs, api_key) do
    data = logs |> Enum.map(&Map.to_list(&1))

    payload = bulk do
      index [index: "logs-#{api_key}", type: "Log"], data
    end

    {:ok, 200, response} = Tirexs.bump!(payload)._bulk()

    Logger.debug("[gateway] elastic response: #{inspect(response)}")

    Pubsub.publish("#{api_key}:logs", %{type: :logs, logs: logs})

    :ok
  end

  @doc """
  Store variables in Redis server and notify subscribers about the updates

  Example:
    <api_key>:vs
      - <varname>:type = string
      - <varname>:value = "testing"
  """
  def vars(vars, api_key) do
    vars = vars
           |> Enum.map(fn var ->
             var
             |> Enum.filter(fn {k, v} -> k != "name" end)
             |> Enum.map(fn {k, v} ->
               ["#{var["name"]}:#{k}", v]
             end)
           end)
           |> List.flatten

    query = ["HMSET", "#{api_key}:vs"] ++ vars
    Redis.query(query)

    Pubsub.publish("#{api_key}:vars", %{type: :vars, vars: vars})

    :ok
  end
end
