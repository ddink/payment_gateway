defmodule PaymentGateway.CartParserTest do
  use PaymentGateway.CartCase
  alias PaymentGateway.CartParser
  doctest CartParser

  test "parse/1 converts cart's data into json string for order transaction", %{ cart: cart } do
    assert json = CartParser.parse(cart)
    assert is_binary(json)
    assert {:ok, _map} = Jason.decode(json)
  end
end
