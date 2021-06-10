defmodule OlmTest do
  use ExUnit.Case

  doctest Olm

  test "version/0" do
    assert String.first(Olm.version()) == "3"
  end
end
