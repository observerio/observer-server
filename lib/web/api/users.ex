defmodule Web.Api.Users do
  use Maru.Router

  alias Web.Db.Users

  namespace :users do
    params do
      requires :email, type: String
      requires :password, type: String
    end
    post do
      if Users.exists?(params[:email]) do
        conn
        |> put_status(400)
        |> text("email exists")
      else
        # TODO: add auth_key using JWT.io
        #
        {:ok, api_key} = Users.register(%{email: params[:email],
                                          password: params[:password]})

        json(conn, %{auth_key: api_key})
      end
    end
  end
end
