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

  test "create_account/0" do
    assert {:ok, account} = NIF.create_account()
    assert is_reference(account)
  end

  test "pickle_account/2" do
    {:ok, account} = NIF.create_account()
    {:ok, pickled_account} = NIF.pickle_account(account, "key")

    assert is_binary(pickled_account)
    assert String.length(pickled_account) == 246
  end

  test "unpickle_account/2" do
    pickled_account =
      "pZeOezYWRpPNM5QzdxevG5NEwmOHSkW02eIwa2yhHzAdi9AakSiuFIViTZH1a2LwqwWXFGZyG0E0DLq3J69ThIhE0GyhFcDMZjvZAvVV0imy4DeUjqWMila2kV7TmbRD4iYVIm0LEBZIDFST3McIm6V4xoTdkJPxjdDKiPhyiyqn1qaikeUrAhg1aoWqmYyA4flZe2HERG0ZSBWfoWT9lW9Tcb+9ZBfEFq7nMq+OKoYAaGzVKf8piA"

    {:ok, account} = NIF.unpickle_account(pickled_account, "key")
    assert is_reference(account)

    {:error, last_error} = NIF.unpickle_account(pickled_account, "wrong_key")

    assert is_list(last_error)
    assert last_error == 'BAD_ACCOUNT_KEY'
  end

  test "account_identity_keys/1" do
    {:ok, account} = NIF.create_account()
    {:ok, identity_keys} = NIF.account_identity_keys(account)

    assert is_binary(identity_keys)
  end

  test "account_sign/2" do
    {:ok, account} = NIF.create_account()
    {:ok, signed} = NIF.account_sign(account, "test")

    assert is_binary(signed)
  end

  test "account_one_time_keys/1" do
    {:ok, account} = NIF.create_account()
    {:ok, keys} = NIF.account_one_time_keys(account)
    {:ok, keys} = Jason.decode(keys, keys: :atoms)

    assert keys == %{curve25519: %{}}
  end

  test "account_mark_keys_as_published/1" do
    {:ok, account} = NIF.create_account()
    {:ok, _} = NIF.account_generate_one_time_keys(account, 1)
    {:ok, msg} = NIF.account_mark_keys_as_published(account)

    assert msg == 'Successfully marked keys as published'
  end

  test "account_max_one_time_keys/1" do
    {:ok, account} = NIF.create_account()
    {:ok, max} = NIF.account_max_one_time_keys(account)

    assert is_integer(max)
  end

  test "account_generate_one_time_keys/2" do
    {:ok, account} = NIF.create_account()
    {:ok, msg} = NIF.account_generate_one_time_keys(account, 1)

    assert msg == 'Successfully generated'
  end
end
