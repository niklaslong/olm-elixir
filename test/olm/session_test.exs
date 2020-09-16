defmodule Olm.SessionTest do
  use ExUnit.Case
  alias Olm.{Session, Account}

  doctest Session

  ExUnit.Case.register_attribute(__MODULE__, :fixtures, accumulate: true)

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

  defp pickle_session(context),
    do: %{pickled_session: Session.pickle(context.outbound_session, "key")}

  defp encrypt_message(context) do
    [%{msg_content: msg_content}] = context.registered.fixtures
    %{pre_key_msg: Session.encrypt_message(context.outbound_session, msg_content)}
  end

  defp create_inbound_session(context) do
    inbound_session =
      Session.new_inbound(context.peer_account, context.pre_key_msg.cyphertext, context.id_key)

    %{inbound_session: inbound_session}
  end

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

    test "returns a session which can be used to decrypt messages (with id key)", context do
      pre_key_msg = Session.encrypt_message(context.outbound_session, "This is a message")

      inbound_session =
        Session.new_inbound(context.peer_account, pre_key_msg.cyphertext, context.id_key)

      assert is_reference(inbound_session)
    end

    test "returns a session which can be used to decrypt messages (without id key)", context do
      pre_key_msg = Session.encrypt_message(context.outbound_session, "This is a message")
      inbound_session = Session.new_inbound(context.peer_account, pre_key_msg.cyphertext)
      assert is_reference(inbound_session)
    end
  end

  describe "id/1:" do
    setup [
      :create_account,
      :create_peer_account,
      :create_outbound_session,
      :encrypt_message,
      :create_inbound_session
    ]

    @fixtures %{msg_content: "This is a message"}
    test "returns session id", context do
      outbound_id = Session.id(context.outbound_session)
      inbound_id = Session.id(context.inbound_session)

      assert is_binary(outbound_id)
      assert outbound_id == inbound_id
    end
  end

  describe "match_inbound/3" do
    setup [
      :create_account,
      :create_peer_account,
      :create_outbound_session,
      :encrypt_message,
      :create_inbound_session
    ]

    @fixtures %{msg_content: "This is a message"}
    test "returns 1 if current inbound session matches pre key message (with id key verification)",
         context do
      assert Session.match_inbound(
               context.inbound_session,
               context.pre_key_msg.cyphertext,
               context.id_key
             ) === 1
    end

    @fixtures %{msg_content: "This is a message"}
    test "returns 1 if current inbound session matches pre key message (without id key verification)",
         context do
      assert Session.match_inbound(context.inbound_session, context.pre_key_msg.cyphertext) === 1
    end
  end

  describe "pickle_session/2:" do
    setup [:create_account, :create_peer_account, :create_outbound_session, :pickle_session]

    test "returns the pickled session as a base64 string", context do
      assert is_binary(Session.pickle(context.outbound_session, "key"))
    end

    test "returns a reference to the unpickle session", context do
      assert is_reference(Session.unpickle(context.pickled_session, "key"))
    end
  end

  describe "encrypt_message/2:" do
    setup [:create_account, :create_peer_account, :create_outbound_session]

    test "returns base64 encoded cyphertext (pre-key)", context do
      message = Session.encrypt_message(context.outbound_session, "message")
      assert is_binary(message.cyphertext)
      assert message.type === 0
    end
  end

  describe "decrypt_message/3" do
    setup [
      :create_account,
      :create_peer_account,
      :create_outbound_session,
      :encrypt_message,
      :create_inbound_session
    ]

    @fixtures %{msg_content: "This is a message"}
    test "returns the decrypted message", context do
      assert Session.decrypt_message(
               context.inbound_session,
               context.pre_key_msg.type,
               context.pre_key_msg.cyphertext
             ) == "This is a message"
    end
  end
end
