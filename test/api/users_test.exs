defmodule Web.RouterTest do
  use ExUnit.Case
  use Maru.Test, for: Web.Router
end

defmodule Web.Api.UsersTest do
  use ExUnit.Case
  doctest Web.Api.Users

  require RedisPoolex
  alias Web.Api.Users

  use Maru.Test, for: Web.Api.Users

  setup do
    RedisPoolex.query(["FLUSHDB"])
    :ok
  end

  test "tokens generation for new users" do
    response = conn(:get, "/users/tokens") |> make_response
    assert response.status == 200
  end

  test "use tokens for register new users despite on missing email" do
  end
end
