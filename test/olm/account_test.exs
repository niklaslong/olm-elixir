defmodule Olm.AccountTest do
  use ExUnit.Case
  alias Olm.Account

  doctest Account

  describe "identity_keys/1:" do
    test "returns a map containing the identity keys for an account" do
      {:ok, account} = Account.create()
      {:ok, keys} = Account.identity_keys(account)

      assert Map.has_key?(keys, :curve25519)
      assert Map.has_key?(keys, :ed25519)

      assert is_binary(keys.curve25519)
      assert is_binary(keys.ed25519)
    end
  end

  describe "one_time_keys/1:" do
    test "returns a map containing the unpublished one time keys for an account (empty)" do
      {:ok, account} = Account.create()
      {:ok, keys} = Account.one_time_keys(account)

      assert keys == %{curve25519: %{}}
    end

    test "returns a map containing the unpublished one time keys for an account (non-empty)" do
      {:ok, account} = Account.create()
      {:ok, _} = Account.generate_one_time_keys(account, n = 2)
      {:ok, keys} = Account.one_time_keys(account)

      assert Map.has_key?(keys, :curve25519)
      assert keys.curve25519 |> Map.keys() |> length() == n
      assert keys.curve25519 |> Map.values() |> Enum.each(&is_binary/1)
    end
  end
end
