defmodule Olm do
  @moduledoc """
  Documentation for `Olm`.
  """

  @on_load :load_nifs

  def load_nifs do
    :erlang.load_nif('priv/native/olm_nifs', 0)
  end

  def version do
    raise "NIF version/0 not implemented"
  end
end
