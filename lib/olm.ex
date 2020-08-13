defmodule Olm do
  @moduledoc """
  Documentation for `Olm`.
  """

  @on_load :load_nifs

  def load_nifs(), do: :erlang.load_nif('priv/native/olm_nifs', 0)

  def version(), do: error("version/0")

  def account_size(), do: error("account_size/0")

  def session_size(), do: error("session_size/0")

  defp error(function_name), do: :erlang.nif_error("NIF #{function_name} not implemented")
end
