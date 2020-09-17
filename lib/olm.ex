defmodule Olm do
  @moduledoc """
  Elixir/Erlang bindings to the olm and megolm cryptographic ratchets.  
  """

  alias Olm.NIF

  @doc """
  The version number of the Olm C library.
  """
  def version() do
    {major, minor, patch} = NIF.version()
    "#{major}.#{minor}.#{patch}"
  end
end
