defmodule Olm.SessionTest do
  use ExUnit.Case
  alias Olm.{Session, Account}

  doctest Session

  defp create_account(_context), do: %{account: Account.create()}

  defp generate_peer_keys(_context) do
    peer_account = Account.create()

    id_key =
      peer_account
      |> Account.identity_keys()
      |> Map.get(:curve25519)

    one_time_key =
      peer_account
      |> Account.generate_one_time_keys(1, true)
      |> get_in([:curve25519, :AAAAAQ])

    %{peer_id_key: id_key, peer_one_time_key: one_time_key}
  end

  defp create_outbound_session(context),
    do: %{
      outbound_session:
        Session.new_outbound(context.account, context.peer_id_key, context.peer_one_time_key)
    }

  describe "new_outbound/3:" do
    setup [:create_account, :generate_peer_keys]

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

  describe "encrypt_message/2:" do
    setup [:create_account, :generate_peer_keys, :create_outbound_session]

    test "returns base64 encoded cyphertext", context do
      assert is_binary(Session.encrypt_message(context.outbound_session, "message"))
    end
  end
end
