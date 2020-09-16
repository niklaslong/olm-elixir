defmodule Olm.Account do
  @moduledoc """
  Functions for working with Olm Accounts.
  """

  alias Olm.{NIF, NIFError}
  alias Jason

  @doc """
  Creates a new account.
  """
  def create() do
    case NIF.create_account() do
      {:ok, account_ref} -> account_ref
      {:error, error} -> raise NIFError, error
    end
  end

  @doc """
  Stores an account as a base64 string. Encrypts the account using the supplied key.
  """
  def pickle(account_ref, key) when is_reference(account_ref) and is_binary(key) do
    case NIF.pickle_account(account_ref, key) do
      {:ok, pickled_account} -> pickled_account
      {:error, error} -> raise NIFError, error
    end
  end

  @doc """
  Loads an account from a pickled base64 string. Decrypts the account using the supplied key.
  """
  def unpickle(pickled_account, key) when is_binary(pickled_account) and is_binary(key) do
    case NIF.unpickle_account(pickled_account, key) do
      {:ok, account_ref} ->
        {:ok, account_ref}

      {:error, 'BAD_ACCOUNT_KEY'} ->
        {:error, "bad account key: can't decrypt the pickled account"}

      {:error, error} ->
        raise NIFError, error
    end
  end

  @doc """
  Returns the public parts of the identity keys for the account. 
  """
  def identity_keys(account_ref) when is_reference(account_ref) do
    case NIF.account_identity_keys(account_ref) do
      {:ok, keys_as_json} -> Jason.decode!(keys_as_json, keys: :atoms)
      {:error, error} -> raise NIFError, error
    end
  end

  @doc """
  Signs a message with the ed25519 key for this account.
  """
  def sign(account_ref, message) when is_reference(account_ref) and is_binary(message) do
    case NIF.account_sign(account_ref, message) do
      {:ok, signed} -> signed
      {:error, error} -> raise NIFError, error
    end
  end

  @doc """
  Returns the public parts of the unpublished one time keys for the account.
  """
  def one_time_keys(account_ref) when is_reference(account_ref) do
    case NIF.account_one_time_keys(account_ref) do
      {:ok, keys_as_json} -> Jason.decode!(keys_as_json, keys: :atoms)
      {:error, error} -> raise NIFError, error
    end
  end

  @doc """
  Marks the current set of one time keys as being published.
  """
  def mark_keys_as_published(account_ref) when is_reference(account_ref) do
    case NIF.account_mark_keys_as_published(account_ref) do
      {:ok, _} -> :ok
      {:error, error} -> raise NIFError, error
    end
  end

  @doc """
  The largest number of one time keys this account can store.
  """
  def max_one_time_keys(account_ref) when is_reference(account_ref) do
    case NIF.account_max_one_time_keys(account_ref) do
      {:ok, max} -> max
      {:error, error} -> raise NIFError, error
    end
  end

  @doc """
  Generates a number of new one time keys.
  """
  def generate_one_time_keys(account_ref, count, return \\ false)
      when is_reference(account_ref) and is_integer(count) and count > 0 do
    result = fn
      false -> :ok
      true -> one_time_keys(account_ref)
    end

    case NIF.account_generate_one_time_keys(account_ref, count) do
      {:ok, _} -> result.(return)
      {:error, error} -> raise NIFError, error
    end
  end

  @doc """
  Removes the one time keys that the session used from the account.
  """
  def remove_one_time_keys(account_ref, session_ref)
      when is_reference(account_ref) and is_reference(session_ref) do
    case NIF.remove_one_time_keys(account_ref, session_ref) do
      {:ok, _} -> :ok
      {:error, error} -> raise NIFError, error
    end
  end
end
