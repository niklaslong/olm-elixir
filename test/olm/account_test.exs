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
end
