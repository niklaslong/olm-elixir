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
  Create a new in-bound session for sending/receiving messages from an incoming PRE_KEY message.
  """
  def new_inbound(account_ref, message) when is_reference(account_ref) and is_binary(message) do
    case NIF.create_inbound_session(account_ref, message) do
      {:ok, session_ref} -> session_ref
      {:error, error} -> raise NIFError, error
    end
  end

  def new_inbound(account_ref, message, peer_id_key)
      when is_reference(account_ref) and is_binary(message) and is_binary(peer_id_key) do
    case NIF.create_inbound_session_from(account_ref, message, peer_id_key) do
      {:ok, session_ref} -> session_ref
      {:error, error} -> raise NIFError, error
    end
  end

  @doc """
  An identifier for this session. 

  Will be the same for both ends of the conversation.
  """
  def id(session_ref) when is_reference(session_ref) do
    case NIF.session_id(session_ref) do
      {:ok, id} -> id
      {:error, error} -> raise NIFError, error
    end
  end

  @doc """
  Checks if the pre key message is for this in-bound session.
  """
  def match_inbound(session_ref, message) when is_reference(session_ref) and is_binary(message) do
    case NIF.match_inbound_session(session_ref, message) do
      {:ok, val} -> val
      {:error, error} -> raise NIFError, error
    end
  end

  def match_inbound(session_ref, message, peer_id_key)
      when is_reference(session_ref) and is_binary(message) and is_binary(peer_id_key) do
    case NIF.match_inbound_session_from(session_ref, message, peer_id_key) do
      {:ok, val} -> val
      {:error, error} -> raise NIFError, error
    end
  end

  @doc """
  Stores a session as a base64 string.
  """
  def pickle(session_ref, key) when is_reference(session_ref) and is_binary(key) do
    case NIF.pickle_session(session_ref, key) do
      {:ok, pickled_session} -> pickled_session
      {:error, error} -> raise NIFError, error
    end
  end

  @doc """
  Loads a session from a pickled base64 string.
  """
  def unpickle(pickled_session, key) when is_binary(pickled_session) and is_binary(key) do
    case NIF.unpickle_session(pickled_session, key) do
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

  @doc """
  Decrypts a message using the session.
  """
  def decrypt_message(session_ref, type, cyphertext)
      when is_reference(session_ref) and is_integer(type) do
    case NIF.decrypt_message(session_ref, type, cyphertext) do
      {:ok, plaintext} ->
        plaintext
        |> String.chunk(:printable)
        |> List.first()

      {error, error} ->
        raise NIFError, error
    end
  end
end
