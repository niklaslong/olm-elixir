defmodule Olm.Session do
  @moduledoc """
  Functions for working with Olm Sessions
  """

  alias Olm.{NIF, NIFError}

  def new_outbound(account_ref, peer_id_key, peer_one_time_key)
      when is_reference(account_ref) and is_binary(peer_id_key) and is_binary(peer_one_time_key) do
    case NIF.create_outbound_session(account_ref, peer_id_key, peer_one_time_key) do
      {:ok, session_ref} -> session_ref
      {:error, error} -> raise NIFError, error
    end
  end

  def encrypt_message(session_ref, plaintext) do
    case NIF.encrypt_message(session_ref, plaintext) do
      {:ok, cyphertext} -> cyphertext
      {:error, error} -> raise NIFError, error
    end
  end
end
