defmodule PaymentGatewayTest do
  use PaymentGateway.CartCase, async: true
  doctest PaymentGateway

  describe "checkout/1" do
    test "when transaction's api call is successfull returns a {:ok, response_body} tuple",
      %{ cart: cart } do
      assert {:ok, response_body} = PaymentGateway.checkout(cart)
      assert is_map(response_body)
    end
  end
end
