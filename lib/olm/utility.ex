defmodule Olm.Utility do
  @moduledoc """
  Olm Utility functions.
  """

  alias Olm.{NIF, NIFError}

  def sha256(to_hash) when is_binary(to_hash) do
    case NIF.utility_sha256(to_hash) do
      {:ok, hash} -> hash
      {:error, error} -> raise NIFError, error
    end
  end

  def verify_ed25519(key, message, signature)
      when is_binary(key) and is_binary(message) and is_binary(signature) do
    case NIF.utility_ed25519_verify(key, message, signature) do
      {:ok, _} -> {:ok, "verified"}
      {:error, 'BAD_MESSAGE_MAC'} -> {:error, "bad message MAC"}
      {:error, error} -> raise NIFError, error
    end
  end
end
