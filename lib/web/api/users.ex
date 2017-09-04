defmodule Web.Api.Users do
  use Maru.Router

  alias Web.Db.Users

  require Logger
  require IEx

  namespace :users do
    params do
      requires :email, type: String
      requires :password, type: String
    end
    post do
      if Users.exists?(%{email: params[:email]}) do
        conn
        |> put_status(400)
        |> json(%{error: "email exists"})
      else
        # TODO: add auth_key using JWT.io
        #
        {:ok, token} = Users.register(%{
          email: params[:email],
          password: params[:password]})

        json(conn, with_token(token))
      end
    end

    namespace :tokens do
      get do
        json(conn, with_token(Users.new_token))
      end

      params do
        requires :token, type: String
      end
      post do
        IEx.pry

        Logger.debug("[/users/tokens] params: #{inspect(params)}")

        token = params[:token]

        Logger.debug("[/users/tokens] received token: #{token}")

        if Users.exists?(%{token: params[:token]}) do
          Logger.debug("[/users/tokens] user exists by token: #{token}")
          json(conn, with_token(token))
        else
          Logger.debug("[/users/tokens] register user by token: #{token}")
          {:ok, _} = Users.register(%{token: token})
          json(conn, with_token(token))
        end
      end
    end

    def with_token(token) do
      %{token: token}
    end
  end
end
