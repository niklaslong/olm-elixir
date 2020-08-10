defmodule OlmTest do
  use ExUnit.Case
  doctest Olm

  test "get olm library version" do
    {major, minor, patch} = Olm.version()

    assert is_integer(major)
    assert is_integer(minor)
    assert is_integer(patch)
  end
end
