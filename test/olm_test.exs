defmodule OlmTest do
  use ExUnit.Case
  doctest Olm

  test "get olm library version" do
    {major, minor, patch} = Olm.version()

    assert is_integer(major)
    assert is_integer(minor)
    assert is_integer(patch)
  end

  test "get session size" do
    assert is_integer(Olm.session_size())
  end

  test "get utiliy size" do
    assert is_integer(Olm.utility_size())
  end

  test "create an account" do
    assert is_reference(Olm.create_account())
  end

  test "returns an account stored as an encrypted base64 string" do
    pickled_account = Olm.create_account() |> Olm.pickle_account('key', 4)

    assert is_list(pickled_account)
    assert length(pickled_account) == 246
  end

  test "returns the public parts of the identity keys for an account" do
    {:ok, keys} =
      Olm.create_account()
      |> Olm.account_identity_keys()
      |> Jason.decode(keys: :atoms)

    assert is_binary(keys.curve25519)
    assert is_binary(keys.ed25519)
  end
end
