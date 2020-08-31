defmodule Olm.Account do
  @moduledoc """
  Functions for working with Olm Accounts.
  """

  alias Olm.NIF
  alias Jason

  @doc """
  Creates a new account.
  """
  def create(), do: NIF.create_account()

  @doc """
  Stores an account as a base64 string. Encrypts the account using the supplied key.
  """
  def pickle(account_ref, key), do: NIF.pickle_account(account_ref, key)

  @doc """
  Loads an account from a pickled base64 string. Decrypts the account using the supplied key.
  """
  def unpickle(pickled_account, key), do: NIF.unpickle_account(pickled_account, key)

  @doc """
  Returns the public parts of the identity keys for the account. 
  """
  def identity_keys(account_ref) do
    with {:ok, keys_as_json} <- NIF.account_identity_keys(account_ref),
         {:ok, decoded_keys} <- Jason.decode(keys_as_json, keys: :atoms) do
      {:ok, decoded_keys}
    else
      error -> error
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
