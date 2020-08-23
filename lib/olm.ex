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

  def init_account(), do: error("init_account/0")

  defp error(function_name), do: :erlang.nif_error("NIF #{function_name} not implemented")
end
