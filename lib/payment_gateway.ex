defmodule PaymentGateway do
  import PaymentGateway.{CartParser, Gateway}

  def checkout(cart) do
    {:checkout, cart} |> call_gateway_api
  end

  def tokenize_credit_card(cart) do
    {:tokenize_credit_card, cart} |> call_gateway_api
  end

  def delete_token(cart) do
    {:delete_token, cart} |> call_gateway_api
  end

  def query_tokens(cart) do
    {:query_tokens, cart} |> call_gateway_api
  end

  def pay_with_token(cart) do
    {:pay_with_token, cart} |> call_gateway_api
  end

  defp call_gateway_api({_request_type, _cart} = request_data) do
    request_data
    |> select_gateway
    |> parse
    |> send_api_call
    |> handle_transaction_response
  end
end
