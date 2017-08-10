defmodule Web.Db.Users do
  require SecureRandom

  alias Comeonin.Bcrypt
  alias RedisPoolex, as: Redis

  def new_token(), do: SecureRandom.hex(6)

  def verify_key(api_key) do
    Redis.query(["EXISTS", api_key]) == "1"
  end

  def exists?(email_or_token) do
    Redis.query(["SISMEMBER", "emails", email_or_token]) == "1" or
    Redis.query(["SISMEMBER", "tokens", email_or_token]) == "1"
  end

  def register(%{token: nil}), do: {:error, :missing_token}
  def register(%{token: token}) do
    Redis.query_pipe([
      ["hmset", token,
       "email", ''],
      ["SADD", "tokens", token],
    ])
    {:ok, token}
  end
  def register(%{email: nil, password: _password}), do: {:error, :missing_email}
  def register(%{email: _email, password: nil}), do: {:error, :missing_password}
  def register(%{email: email, password: password}) do
    token = new_token

    Redis.query_pipe([
      ["hmset", token,
       "email", email,
       "password", Bcrypt.hashpwsalt(password)],
      ["SADD", "tokens", token],
      ["SADD", "emails", email],
    ])

    {:ok, token}
  end
end
