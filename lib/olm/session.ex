defmodule Olm.Session do
  @moduledoc """
  Functions for working with Olm Sessions
  """

  alias Olm.{NIF, NIFError}

  @doc """
  Creates a new out-bound session for sending messages to a given peer identity key and one time key.
  """
  def new_outbound(account_ref, peer_id_key, peer_one_time_key)
      when is_reference(account_ref) and is_binary(peer_id_key) and is_binary(peer_one_time_key) do
    case NIF.create_outbound_session(account_ref, peer_id_key, peer_one_time_key) do
      {:ok, session_ref} -> session_ref
      {:error, error} -> raise NIFError, error
    end
  end

  @doc """
  Encrypts a message using the session.
  """
  def encrypt_message(session_ref, plaintext)
      when is_reference(session_ref) and is_binary(plaintext) do
    type =
      case NIF.encrypt_message_type(session_ref) do
        {:ok, type} -> type
        {:error, error} -> raise NIFError, error
      end

    case NIF.encrypt_message(session_ref, plaintext) do
      {:ok, cyphertext} -> %{cyphertext: cyphertext, type: type}
      {:error, error} -> raise NIFError, error
    end
  end
end
