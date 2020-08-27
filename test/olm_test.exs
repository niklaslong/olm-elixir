defmodule OlmTest do
  use ExUnit.Case
  doctest Olm

  test "get olm library version" do
    {major, minor, patch} = Olm.version()

    assert is_integer(major)
    assert is_integer(minor)
    assert is_integer(patch)
  end

  test "create an account" do
    assert is_reference(Olm.create_account())
  end

  test "encrypts an account stored as a base64 string" do
    pickled_account = Olm.create_account() |> Olm.pickle_account("key")

    assert is_binary(pickled_account)
    assert String.length(pickled_account) == 246
  end

  test "decrypts an account stored as a base64 string" do
    pickled_account =
      "pZeOezYWRpPNM5QzdxevG5NEwmOHSkW02eIwa2yhHzAdi9AakSiuFIViTZH1a2LwqwWXFGZyG0E0DLq3J69ThIhE0GyhFcDMZjvZAvVV0imy4DeUjqWMila2kV7TmbRD4iYVIm0LEBZIDFST3McIm6V4xoTdkJPxjdDKiPhyiyqn1qaikeUrAhg1aoWqmYyA4flZe2HERG0ZSBWfoWT9lW9Tcb+9ZBfEFq7nMq+OKoYAaGzVKf8piA"

    account = Olm.unpickle_account(pickled_account, "key")

    assert is_reference(account)
    assert Olm.account_last_error(account) == 'SUCCESS'
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
