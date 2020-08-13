defmodule OlmTest do
  use ExUnit.Case
  doctest Olm

  test "get olm library version" do
    {major, minor, patch} = Olm.version()

    assert is_integer(major)
    assert is_integer(minor)
    assert is_integer(patch)
  end

  test "get account size" do
    assert is_integer(Olm.account_size())
  end

  test "get session size" do
    assert is_integer(Olm.session_size())
  end

  test "get utiliy size" do
    assert is_integer(Olm.utility_size())
  end
end
