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

  # def remove_one_time_keys(_account_ref, _session_ref), do: error("remove_one_time_keys/2")

  def create_outbound_session(_account_ref, _peer_id_key, _peer_one_time_key),
    do: error("create_outbound_session/3")

  def create_inbound_session(_account_ref, _message), do: error("create_inbound_session/2")

  def create_inbound_session_from(_account_ref, _message, _peer_id_key),
    do: error("create_inbound_session_from/3")

  # def session_id(_session_ref), do: error("session_id/1")

  def match_inbound_session(_session_ref, _message), do: error("match_inbound_session/2")

  def match_inbound_session_from(_session_ref, _message, _peer_id_key),
    do: error("match_inbound_session_from/3")

  # def pickle_session(_session_ref, _key), do: error("pickle_session/2")

  # def unpickle_session(_pickled_session, _key), do: error("unpickle_session/2") 

  def encrypt_message_type(_session_ref), do: error("encrypt_message_type/1")

  def encrypt_message(_session_ref, _plaintext), do: error("encrypt_message/2")

  def decrypt_message(_session_ref, _type, _cyphertext), do: error("decrypt_message/3")

  def utility_sha256(_string), do: error("utility_sha256/1")

  def utility_ed25519_verify(_key, _message, _signature), do: error("utility_ed25519_verify/3")

  defp error(function_name), do: :erlang.nif_error("NIF #{function_name} not implemented")
end
