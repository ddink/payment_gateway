defmodule PaymentGateway.SignatureEncoderTest do
  use PaymentGateway.CartCase, async: true

  test "reference_code/1 returns string with cart's first sku, env & date stamp", %{ cart: cart} do
    ref_code_list =
      cart
      |> reference_code
      |> String.split("_")

    env =
      ref_code_list
      |> Enum.at(1)
      |> String.downcase
      |> String.to_atom

    assert Map.has_key?(cart.skus, Enum.at(ref_code_list, 0))
    assert env == Mix.env()
    assert Enum.at(ref_code_list, 2) == Date.to_string(Date.utc_today)
  end

  test "order_signature/1 returns md5 hash", %{ cart: cart } do
    assert String.length(order_signature(cart)) == String.length(md5_hash("foo"))
  end

  test "device_session_id_signature/1 returns md5 hash", %{ cart: cart } do
    assert String.length(device_session_id_signature(cart.cookie)) == String.length(md5_hash("bar"))
  end

  defp md5_hash(string) do
    :crypto.hash(:md5, string) |> Base.encode16(case: :lower)
  end
end
