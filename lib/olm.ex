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
  The size of an account object in bytes.
  """
  def account_size(), do: error("account_size/0")

  @doc """
  The size of an session object in bytes.
  """
  def session_size(), do: error("session_size/0")

  @doc """
  The size of an utility object in bytes.
  """
  def utility_size(), do: error("utility_size/0")

  @doc """
  Initialises an account object using the supplied memory.
  The supplied memory must be at least `account_size/0` bytes.
  """
  def init_account(_account_size), do: error("init_account/1")

  @doc """
  Initialises a session object using the supplied memory.
  The supplied memory must be at least `session_size/0` bytes.
  """
  def init_session(_session_size), do: error("init_session/1")

  @doc """
  Initialises a utility object using the supplied memory.
  The supplied memory must be at least `utility_size/0` bytes.
  """
  def init_utility(_utility_size), do: error("init_utility/1")

  @doc """
  A null terminated string describing the most recent error to happen to an account.
  """
  def account_last_error(_account_ref), do: error("account_last_error/1")

  @doc """
  Returns the number of bytes needed to store an account.
  """
  def pickle_account_length(_account_ref), do: error("pickle_account_length/1")

  def pickle_account(_account_ref, _key, _key_length), do: error("pickle_account/3")

  defp error(function_name), do: :erlang.nif_error("NIF #{function_name} not implemented")
end
