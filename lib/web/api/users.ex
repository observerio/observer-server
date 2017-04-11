defmodule Web.Api.Users do
  use Maru.Router

  alias Web.Db.Users

  namespace :users do
    params do
      requires :email, type: String
      requires :password, type: String
    end
    post do
      unless Users.exists?(params[:email]) do
        {:ok, api_key} = Users.register(%{email: params[:email],
                                          password: params[:password]})
        json(conn, %{api_key: api_key})
      else
        conn
        |> put_status(400)
        |> text("email exists")
      end
    end
  end
end
