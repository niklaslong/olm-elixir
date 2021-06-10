defmodule OlmTest do
  use ExUnit.Case

  doctest Olm

  test "version/0" do
    assert Olm.version() == "3.2.4"
  end
end
