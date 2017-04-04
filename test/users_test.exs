defmodule Web.Db.UsersTest do
  use ExUnit.Case
  doctest Web.Db.Users

  require RedisPoolex
  alias Web.Db.Users

  setup do
    RedisPoolex.query(["FLUSHDB"])
    {:ok, email: "user1@example.com", password: "12345678"}
  end

  test "registration process for newly users", %{email: email, password: password} do
    assert {:error, :missing_email} = Users.register(%{email: nil, password: password})
    assert {:error, :missing_password} = Users.register(%{email: email, password: nil})
    assert {:ok, api_key} = Users.register(%{email: email, password: password})
  end

  test "verification process for api keys", %{email: email, password: password} do
    assert Users.verify_key("none") == false
    {:ok, api_key} = Users.register(%{email: email, password: password})
    assert Users.verify_key(api_key) == true
  end
end
