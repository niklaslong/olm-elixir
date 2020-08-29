defmodule Olm.NIFTest do
  use ExUnit.Case
  alias Olm.NIF

  doctest NIF

  test "version/0" do
    {major, minor, patch} = NIF.version()

    assert is_integer(major)
    assert is_integer(minor)
    assert is_integer(patch)
  end

  test "account_last_error/1" do
    assert NIF.create_account()
           |> NIF.account_last_error() == 'SUCCESS'
  end

  test "create_account/0" do
    assert is_reference(NIF.create_account())
  end

  test "pickle_account/2" do
    pickled_account = NIF.create_account() |> NIF.pickle_account("key")

    assert is_binary(pickled_account)
    assert String.length(pickled_account) == 246
  end

  test "unpickle_account/2" do
    pickled_account =
      "pZeOezYWRpPNM5QzdxevG5NEwmOHSkW02eIwa2yhHzAdi9AakSiuFIViTZH1a2LwqwWXFGZyG0E0DLq3J69ThIhE0GyhFcDMZjvZAvVV0imy4DeUjqWMila2kV7TmbRD4iYVIm0LEBZIDFST3McIm6V4xoTdkJPxjdDKiPhyiyqn1qaikeUrAhg1aoWqmYyA4flZe2HERG0ZSBWfoWT9lW9Tcb+9ZBfEFq7nMq+OKoYAaGzVKf8piA"

    account = NIF.unpickle_account(pickled_account, "key")

    assert is_reference(account)
    assert NIF.account_last_error(account) == 'SUCCESS'
  end

  test "account_identity_keys/1" do
    {:ok, keys} =
      NIF.create_account()
      |> NIF.account_identity_keys()
      |> Jason.decode(keys: :atoms)

    assert is_binary(keys.curve25519)
    assert is_binary(keys.ed25519)
  end

  test "account_sign/2" do
    assert NIF.create_account()
           |> NIF.account_sign("test")
           |> is_binary()
  end

  test "account_one_time_keys/1" do
    {:ok, keys} =
      NIF.create_account()
      |> NIF.account_one_time_keys()
      |> Jason.decode(keys: :atoms)

    assert keys == %{curve25519: %{}}
  end

  test "account_mark_keys_as_published/1" do
    account = NIF.create_account()
    NIF.account_generate_one_time_keys(account, 1)
    NIF.account_mark_keys_as_published(account)

    {:ok, keys} =
      account
      |> NIF.account_one_time_keys()
      |> Jason.decode(keys: :atoms)

    assert keys == %{curve25519: %{}}
  end

  test "account_max_one_time_keys/1" do
    assert NIF.create_account()
           |> NIF.account_max_one_time_keys()
           |> is_integer()
  end

  test "account_generate_one_time_keys/2" do
    account = NIF.create_account()

    NIF.account_generate_one_time_keys(account, 1)

    {:ok, keys} =
      account
      |> NIF.account_one_time_keys()
      |> Jason.decode(keys: :atoms)

    assert Map.has_key?(keys, :curve25519)
  end
end
