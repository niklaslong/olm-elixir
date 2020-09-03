defmodule Olm.AccountTest do
  use ExUnit.Case
  alias Olm.Account

  doctest Account

  defp create_account(_context), do: %{account: Account.create()}
  defp pickle_account(context), do: %{pickled_account: Account.pickle(context.account, "key")}

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

  describe "unpickle/2:" do
    setup [:create_account, :pickle_account]

    test "returns a reference to the unpickled account", context do
      assert {:ok, account} = Account.unpickle(context.pickled_account, "key")
      assert is_reference(account)
    end

    test "returns an error when wrong key is given to decrypt the account", context do
      assert {:error, msg} = Account.unpickle(context[:pickled_account], "wrong_key")
      assert msg == "bad account key: can't decrypt the pickled account"
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
