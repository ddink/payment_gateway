defmodule PaymentGateway.CartParser do

  import PaymentGateway.OrderRequestBuilder

  def parse(cart) do
    cart
    |> add_merchant_info
    |> add_transaction_order
    |> add_transaction_buyer
    |> add_transaction_shipping_address
    |> add_payer
    |> add_credit_card
    |> add_extra_parameters
    |> add_test
    |> encode
  end
end
