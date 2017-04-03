defmodule WebTest do
  use ExUnit.Case
  doctest Web

  test "should register user session" do
    {:ok, pid} = Web.Server.start_link([])
    
  end
end
