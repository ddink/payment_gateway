defmodule PaymentGateway.CartParserTest do
  use PaymentGateway.CartCase, async: true
  import PaymentGateway.CartParser

  describe "parse/1" do
    test "returns all data required for cart checkout transaction request", %{ cart: cart } do
      assert {:ok, :payu_latam, _url, _request_body, _headers, _options} = parse({:payu_latam, :checkout, cart})
    end

    test "returns error for unrecognized gateways" do
      assert parse({:epay, :checkout, %{}}) == {:error, "unrecognized gateway"}
    end

    test "returns error tuple when receiving {:error, _reason} tuple" do
      assert {:error, reason} = parse({:error, "generic error message"})
      assert reason == "generic error message"
    end
  end

  describe "select_gateway/1" do
    test "returns {:payu_latam, _} tuple
          when cart.payment_country is one of [CO, BR, PA, CL, AR, PE, MX]", %{ cart: cart } do
      assert {:payu_latam, :checkout, _cart} = select_gateway({:checkout, cart})
      assert {:payu_latam, :checkout, _cart} = select_gateway({:checkout, %{ order: %{payment_country: "BR"} }})
    end

    test "returns {:error, _} tuple when cart.payment country is not in the payu latam list" do
      assert {:error, _} = select_gateway({:checkout, %{ order: %{payment_country: "US"} }})
    end
  end
end
