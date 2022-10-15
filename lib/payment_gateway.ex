defmodule PaymentGateway do
  import PaymentGateway.{CartParser, Gateway}

  def checkout(cart) do
    cart
    |> select_gateway
    |> parse
    |> send_api_call
    |> handle_transaction_response
  end
end
