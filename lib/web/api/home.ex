defmodule Web.Api.Home do
  require SecureRandom

  use Maru.Router

  alias Web.Db.Home

  namespace :tokens do
    get do
      api_key = SecureRandom.hex(6)
      json(conn, %{auth_key: api_key})
    end

    post do
      json(conn, %{auth_key: api_key})
    end
  end
end
