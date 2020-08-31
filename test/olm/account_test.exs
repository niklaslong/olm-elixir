defmodule Olm.AccountTest do
  use ExUnit.Case
  alias Olm.Account

  doctest Account

  describe "create/0:" do
    test "returns a reference to an account resource" do
      assert Account.create() |> is_reference()
    end
  end

  describe "pickle/2:" do
    test "returns the pickled account as a base64 string" do
      assert Account.create() |> Account.pickle("key") |> is_binary()
    end
  end

  describe "identity_keys/1:" do
    test "returns a map containing the identity keys for an account" do
      {:ok, keys} = Account.create() |> Account.identity_keys()

      assert Map.has_key?(keys, :curve25519)
      assert Map.has_key?(keys, :ed25519)

      assert is_binary(keys.curve25519)
      assert is_binary(keys.ed25519)
    end
  end

  describe "one_time_keys/1:" do
    test "returns a map containing the unpublished one time keys for an account (empty)" do
      {:ok, keys} = Account.create() |> Account.one_time_keys()

      assert keys == %{curve25519: %{}}
    end

    test "returns a map containing the unpublished one time keys for an account (non-empty)" do
      account = Account.create()
      {:ok, _} = Account.generate_one_time_keys(account, n = 2)
      {:ok, keys} = Account.one_time_keys(account)

      assert Map.has_key?(keys, :curve25519)
      assert keys.curve25519 |> Map.keys() |> length() == n
      assert keys.curve25519 |> Map.values() |> Enum.each(&is_binary/1)
    end
  end
end
