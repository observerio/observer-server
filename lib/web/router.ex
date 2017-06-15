defmodule Web.Router do
  use Maru.Router

  before do
    plug Plug.Logger
    plug Plug.Static, at: "/dashboard", from: "/my/static/path/"
  end

  plug Plug.Parsers,
    pass: ["*/*"],
    json_decoder: Poison,
    parsers: [:urlencoded, :json, :multipart]

  mount Web.Api.Users
  mount Web.Api.Home

  get "/" do
    data = "public/dist/index.html"
           |> Path.expand
           |> File.read!
    conn |> send_resp(200, data)
  end
end
