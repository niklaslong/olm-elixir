defmodule Olm.NIFError do
  defexception [:message]

  @impl true
  def exception(value) do
    msg = "something is breaking in the C NIF, got: #{inspect(value)}"
    %Olm.NIFError{message: msg}
  end
end

defmodule Olm.NIF do
  @moduledoc false

  @on_load :load_nifs

  def load_nifs(),
    do:
      __DIR__
      |> Path.join("../../priv/olm_nif")
      |> :erlang.load_nif(0)

  def version(), do: error(__ENV__.function())

  def create_account(), do: error(__ENV__.function())

  def pickle_account(_account_ref, _key), do: error(__ENV__.function())

  def unpickle_account(_pickled_account, _key), do: error(__ENV__.function())

  def account_identity_keys(_account_ref), do: error(__ENV__.function())

  def account_sign(_account_ref, _message), do: error(__ENV__.function())

  def account_one_time_keys(_account_ref), do: error(__ENV__.function())

  def account_mark_keys_as_published(_account_ref), do: error(__ENV__.function())

  def account_max_one_time_keys(_account_ref), do: error(__ENV__.function())

  def account_generate_one_time_keys(_account_ref, _count),
    do: error(__ENV__.function())

  def remove_one_time_keys(_account_ref, _session_ref), do: error(__ENV__.function())

  def create_outbound_session(_account_ref, _peer_id_key, _peer_one_time_key),
    do: error(__ENV__.function())

  def create_inbound_session(_account_ref, _message), do: error(__ENV__.function())

  def create_inbound_session_from(_account_ref, _message, _peer_id_key),
    do: error(__ENV__.function())

  def session_id(_session_ref), do: error(__ENV__.function())

  def match_inbound_session(_session_ref, _message), do: error(__ENV__.function())

  def match_inbound_session_from(_session_ref, _message, _peer_id_key),
    do: error(__ENV__.function())

  def pickle_session(_session_ref, _key), do: error(__ENV__.function())

  def unpickle_session(_pickled_session, _key), do: error(__ENV__.function())

  def encrypt_message_type(_session_ref), do: error(__ENV__.function())

  def encrypt_message(_session_ref, _plaintext), do: error(__ENV__.function())

  def decrypt_message(_session_ref, _type, _cyphertext), do: error(__ENV__.function())

  def utility_sha256(_string), do: error(__ENV__.function())

  def utility_ed25519_verify(_key, _message, _signature), do: error(__ENV__.function())

  defp error({function_name, arity}),
    do: :erlang.nif_error("NIF #{function_name}/#{arity} not implemented")
end
