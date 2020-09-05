defmodule Olm.NIFError do
  defexception [:message]

  @impl true
  def exception(value) do
    msg = "something is breaking in the C NIF, got: #{inspect(value)}"
    %Olm.NIFError{message: msg}
  end
end

defmodule Olm.NIF do
  @on_load :load_nifs

  def load_nifs(), do: :erlang.load_nif('priv/olm_nif', 0)

  def version(), do: error("version/0")

  def create_account(), do: error("create_account/0")

  def pickle_account(_account_ref, _key), do: error("pickle_account/2")

  def unpickle_account(_pickled_account, _key), do: error("unpickle_account/2")

  def account_identity_keys(_account_ref), do: error("account_identity_keys/1")

  def account_sign(_account_ref, _message), do: error("account_sign/2")

  def account_one_time_keys(_account_ref), do: error("account_one_time_keys/1")

  def account_mark_keys_as_published(_account_ref), do: error("account_mark_keys_as_published/1")

  def account_max_one_time_keys(_account_ref), do: error("account_max_one_time_keys/1")

  def account_generate_one_time_keys(_account_ref, _count),
    do: error("account_generate_one_time_keys/2")

  def utility_sha256(_string), do: error("utility_sha256/1")

  defp error(function_name), do: :erlang.nif_error("NIF #{function_name} not implemented")
end
