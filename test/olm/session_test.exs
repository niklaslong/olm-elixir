defmodule Olm.SessionTest do
  use ExUnit.Case
  alias Olm.{Session, Account}

  doctest Session

  defp create_account(_context) do
    {account, id_key, one_time_key} = Account.create() |> generate_keys()
    %{id_key: id_key, one_time_key: one_time_key, account: account}
  end

  defp create_peer_account(_context) do
    {account, id_key, one_time_key} = Account.create() |> generate_keys()
    %{peer_id_key: id_key, peer_one_time_key: one_time_key, peer_account: account}
  end

  defp generate_keys(account) do
    id_key =
      account
      |> Account.identity_keys()
      |> Map.get(:curve25519)

    one_time_key =
      account
      |> Account.generate_one_time_keys(1, true)
      |> get_in([:curve25519, :AAAAAQ])

    {account, id_key, one_time_key}
  end

  defp create_outbound_session(context),
    do: %{
      outbound_session:
        Session.new_outbound(context.account, context.peer_id_key, context.peer_one_time_key)
    }

  describe "new_outbound/3:" do
    setup [:create_account, :create_peer_account]

    test "returns a reference to an outbound session", context do
      assert is_reference(
               Session.new_outbound(
                 context.account,
                 context.peer_id_key,
                 context.peer_one_time_key
               )
             )
    end
  end

  describe "new_inbound/3" do
    setup [:create_account, :create_peer_account, :create_outbound_session]

    test "returns a session which can be used to decrypt messages", context do
      pre_key_msg = Session.encrypt_message(context.outbound_session, "this is a secret")

      inbound_session =
        Session.new_inbound(context.peer_account, pre_key_msg.cyphertext, context.id_key)

      assert is_reference(inbound_session)
    end
  end

  describe "encrypt_message/2:" do
    setup [:create_account, :create_peer_account, :create_outbound_session]

    test "returns base64 encoded cyphertext (pre-key)", context do
      message = Session.encrypt_message(context.outbound_session, "message")
      assert is_binary(message.cyphertext)
      assert message.type === 0
    end

    @tag :skip
    test "returns base64 encoded cyphertext (message)", _context do
    end
  end
end
