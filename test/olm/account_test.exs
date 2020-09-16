defmodule Olm.AccountTest do
  use ExUnit.Case
  alias Olm.{Account, Session}

  doctest Account

  defp create_account(_context), do: %{account: Account.create()}
  defp pickle_account(context), do: %{pickled_account: Account.pickle(context.account, "key")}

  describe "create/0:" do
    test "returns a reference to an account resource" do
      assert is_reference(Account.create())
    end
  end

  describe "pickle/2:" do
    setup :create_account

    test "returns the pickled account as a base64 string", context do
      assert context.account |> Account.pickle("key") |> is_binary()
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
    setup :create_account

    test "returns a map containing the identity keys for an account", context do
      keys = Account.identity_keys(context.account)

      assert Map.has_key?(keys, :curve25519)
      assert Map.has_key?(keys, :ed25519)

      assert is_binary(keys.curve25519)
      assert is_binary(keys.ed25519)
    end
  end

  describe "sign/2:" do
    setup :create_account

    test "returns the message signed with the ed25519 key", context do
      assert context.account |> Account.sign("message") |> is_binary
    end
  end

  describe "one_time_keys/1:" do
    setup :create_account

    test "returns a map of unpublished one time keys for an account (empty)", context do
      assert Account.one_time_keys(context.account) == %{curve25519: %{}}
    end

    test "returns a map of unpublished one time keys for an account (non-empty)", context do
      :ok = Account.generate_one_time_keys(context.account, n = 2)
      keys = Account.one_time_keys(context.account)

      assert Map.has_key?(keys, :curve25519)
      assert keys.curve25519 |> Map.keys() |> length() == n
      assert keys.curve25519 |> Map.values() |> Enum.each(&is_binary/1)
    end
  end

  describe "mark_keys_as_published/1:" do
    setup :create_account

    test "returns :ok after marking keys as published", context do
      assert Account.mark_keys_as_published(context.account) == :ok
    end
  end

  describe "max_one_time_keys/1:" do
    setup :create_account

    test "returns max number of one time keys for an account", context do
      assert context.account |> Account.max_one_time_keys() |> is_integer()
    end
  end

  describe "generate_one_time_keys/2" do
    setup :create_account

    test "returns :ok after generating accounts", context do
      assert Account.generate_one_time_keys(context.account, 1) == :ok
    end

    test "returns one time keys if return is set to true", context do
      assert context.account |> Account.generate_one_time_keys(3, true) |> is_map
    end
  end

  describe "remove_one_time_keys/2:" do
    setup :create_account

    test "returns :ok after removing used one time keys", context do
      peer_account = Account.create()

      id_key =
        peer_account
        |> Account.identity_keys()
        |> Map.get(:curve25519)

      one_time_key =
        peer_account
        |> Account.generate_one_time_keys(1, true)
        |> get_in([:curve25519, :AAAAAQ])

      outbound_session = Session.new_outbound(context.account, id_key, one_time_key)
      pre_key_msg = Session.encrypt_message(outbound_session, "message")
      inbound_session = Session.new_inbound(peer_account, pre_key_msg.cyphertext)

      assert :ok = Account.remove_one_time_keys(peer_account, inbound_session)
      assert Account.one_time_keys(peer_account) == %{curve25519: %{}}
    end
  end
end
