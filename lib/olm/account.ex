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
  def sign(account_ref, message), do: NIF.account_sign(account_ref, message)

  @doc """
  Returns the public parts of the unpublished one time keys for the account.
  """
  def one_time_keys(account_ref) do
    with {:ok, keys_as_json} <- NIF.account_one_time_keys(account_ref),
         {:ok, decoded_keys} <- Jason.decode(keys_as_json, keys: :atoms) do
      {:ok, decoded_keys}
    else
      error -> error
    end
  end

  @doc """
  Marks the current set of one time keys as being published.
  """
  def mark_keys_as_published(account_ref), do: NIF.account_mark_keys_as_published(account_ref)

  @doc """
  The largest number of one time keys this account can store.
  """
  def max_one_time_keys(account_ref), do: NIF.account_max_one_time_keys(account_ref)

  @doc """
  Generates a number of new one time keys.
  """
  def generate_one_time_keys(account_ref, count),
    do: NIF.account_generate_one_time_keys(account_ref, count)
end
