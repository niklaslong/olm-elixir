defmodule Olm do
  @moduledoc """
  Documentation for `Olm`.
  """

  @on_load :load_nifs

  def load_nifs(), do: :erlang.load_nif('priv/native/olm_nifs', 0)

  @doc """
  The version number of the library.
  """
  def version(), do: error("version/0")

  @doc """
  A null terminated string describing the most recent error to happen to a session.
  """
  def account_last_error(_account_ref), do: error("account_last_error/1")

  @doc """
  Creates a new account.
  """
  def create_account(), do: error("create_account/0")

  @doc """
  Stores an account as a base64 string. Encrypts the account using the supplied key.
  """
  def pickle_account(_account_ref, _key), do: error("pickle_account/2")

  @doc """
  Loads an account from a pickled base64 string. Decrypts the account using the supplied key.
  """
  def unpickle_account(_pickled_account, _key), do: error("unpickle_account/2")

  @doc """
  Returns the public parts of the identity keys for the account. 
  """
  def account_identity_keys(_account_ref), do: error("account_identity_keys/1")

  defp error(function_name), do: :erlang.nif_error("NIF #{function_name} not implemented")
end
