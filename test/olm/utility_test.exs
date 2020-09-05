defmodule Olm.UtilityTest do
  use ExUnit.Case
  alias Olm.Utility

  doctest Utility

  describe "sha256/1:" do
    test "returns a hash of the input string" do
      assert "input" |> Utility.sha256() |> is_binary
    end
  end
end
