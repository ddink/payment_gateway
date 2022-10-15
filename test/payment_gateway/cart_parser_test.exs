defmodule PaymentGateway.CartParserTest do
  use PaymentGateway.CartCase, async: true
  alias PaymentGateway.CartParser
  doctest CartParser

  describe "parse/1" do
    test "returns all data required for order transaction request", %{ cart: cart } do
      assert {:ok, :payu_latam, _url, _request_body, _headers} = CartParser.parse({:payu_latam, cart})
    end

    test "returns error for unrecognized gateways" do
      assert CartParser.parse({:epay, %{}}) == {:error, "unrecognized gateway"}
    end

    test "returns error tuple when receiving {:error, _reason} tuple" do
      assert {:error, reason} = CartParser.parse({:error, "generic error message"})
      assert reason == "generic error message"
    end
  end

  describe "select_gateway/1" do
    test "returns {:payu_latam, _} tuple
          when cart.payment_country is one of [CO, BR, PA, CL, AR, PE, MX]", %{ cart: cart } do
      assert {:payu_latam, _cart} = CartParser.select_gateway(cart)
      assert {:payu_latam, _cart} = CartParser.select_gateway(%{ order: %{payment_country: "BR"} })
    end

    test "returns {:error, _} tuple when cart.payment country is not in the payu latam list" do
      assert {:error, _} = CartParser.select_gateway(%{ order: %{payment_country: "US"} })
    end
  end
end
