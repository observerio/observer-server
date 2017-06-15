defmodule Web.Api.Home do
  require SecureRandom

  use Maru.Router

  namespace :tokens do
    get do
      api_key = SecureRandom.hex(6)
      json(conn, %{apiKey: api_key})
    end

    post do
      json(conn, %{status: :ok})
    end
  end
end
