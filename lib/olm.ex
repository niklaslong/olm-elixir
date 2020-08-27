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
  The size of an session object in bytes.
  """
  def session_size(), do: error("session_size/0")

  @doc """
  The size of an utility object in bytes.
  """
  def utility_size(), do: error("utility_size/0")

  def account_last_error(_account_ref), do: error("account_last_error/1")

  @doc """
  Creates a new account.
  """
  def create_account(), do: error("create_account/0")

  @doc """
  Stores an account as a base64 string. Encrypts the account using the supplied key.
  """
  def pickle_account(_account_ref, _key, _key_length), do: error("pickle_account/3")

  def unpickle_account(_pickled_account, _pickled_length, _key, _key_length),
    do: error("unpickle_account/3")

  @doc """
  Returns the public parts of the identity keys for the account. 
  """
  def account_identity_keys(_account_ref), do: error("account_identity_keys/1")

  defp error(function_name), do: :erlang.nif_error("NIF #{function_name} not implemented")
end
