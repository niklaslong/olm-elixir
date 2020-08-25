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

  test "initiliase an account" do
    assert Olm.account_size()
           |> Olm.init_account()
           |> is_reference()
  end

  test "initiliase a session" do
    assert Olm.session_size()
           |> Olm.init_session()
           |> is_reference()
  end

  test "initiliase a utility" do
    assert Olm.utility_size()
           |> Olm.init_utility()
           |> is_reference()
  end

  test "returns the most recent error to happen to an account" do
    charlist =
      Olm.account_size()
      |> Olm.init_account()
      |> Olm.account_last_error()

    assert is_list(charlist)
    assert 'SUCCESS' == charlist
  end

  test "returns number of bytest needed to store an account" do
    pickled_length =
      Olm.account_size()
      |> Olm.init_account()
      |> Olm.pickle_account_length()

    assert is_integer(pickled_length)
    # Don't know if this value is consistent...
    assert pickled_length == 246
  end

  test "returns an account stored as an encrypted base64 string" do
    pickled_account =
      Olm.account_size()
      |> Olm.init_account()
      |> Olm.pickle_account('key', 4)

    assert is_list(pickled_account)
    assert length(pickled_account) == 246
  end
end
