defmodule Olm.Utility do
  @moduledoc """
  Olm Utility functions.
  """

  alias Olm.{NIF, NIFError}

  def sha256(to_hash) when is_binary(to_hash) do
    case NIF.utility_sha256(to_hash) do
      {:ok, hash} -> hash
      {:error, error} -> raise NIFError, error
    end
  end
end
