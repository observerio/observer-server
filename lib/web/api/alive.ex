defmodule Web.Api.Status do
  use Maru.Router

  get "/alive" do
    json(conn, %{status: "ok"})
  end
end
