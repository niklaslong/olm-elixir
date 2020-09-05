defmodule Olm.UtilityTest do
  use ExUnit.Case
  alias Olm.{Utility, Account}

  doctest Utility

  defp create_account(_context), do: %{account: Account.create()}
  defp identity_keys(context), do: %{identity_keys: Account.identity_keys(context.account)}
  defp sign(context), do: %{signature: Account.sign(context.account, "test")}

  describe "sha256/1:" do
    test "returns a hash of the input string" do
      assert "input" |> Utility.sha256() |> is_binary
    end
  end

  describe "verify_ed25519/3:" do
    setup [:create_account, :identity_keys, :sign]

    test "verifies signature", context do
      {:ok, msg} =
        Utility.verify_ed25519(context.identity_keys.ed25519, "test", context.signature)

      assert msg == "verified"
    end

    test "returns error for bad signature", context do
      {:error, msg} =
        Utility.verify_ed25519(context.identity_keys.ed25519, "bad_msg", context.signature)

      assert msg == "bad message MAC"
    end
  end
end
