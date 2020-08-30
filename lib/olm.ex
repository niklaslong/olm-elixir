defmodule Olm do
  @moduledoc """
  Documentation for `Olm`.
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
