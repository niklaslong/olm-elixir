defmodule OlmTest do
  use ExUnit.Case

  doctest Olm

  test "version/0" do
    assert Olm.version() == "3.1.5"
  end
end
