defmodule AzanRestApiTest do
  use ExUnit.Case
  doctest AzanRestApi

  test "greets the world" do
    assert AzanRestApi.hello() == :world
  end
end
