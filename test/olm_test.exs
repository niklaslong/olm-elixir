defmodule OlmTest do
  use ExUnit.Case
  doctest Olm

  test "greets the world" do
    assert Olm.hello() == :world
  end
end
