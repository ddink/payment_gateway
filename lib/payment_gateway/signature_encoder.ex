defmodule PaymentGateway.SignatureEncoder do

  # to be stored as environment/config variables
  @merchant_api_key "4Vj8eK4rloUd272L48hsrarnUA"
  @merchant_account_id "508029"

  def reference_code(cart) do
    "#{first_sku(cart)}_#{env()}_#{Date.utc_today}"
  end

  defp first_sku(cart) do
    cart.order.skus
    |> Map.keys
    |> List.first
  end

  defp env() do
    Mix.env()
    |> Atom.to_string
    |> String.upcase
  end

  def order_description() do
    "Payment test description"
  end

  def order_signature(cart) do
    string = "#{@merchant_api_key}~#{@merchant_account_id}~"<>
             "#{reference_code(cart)}~#{cart.order.total_transaction_price}~#{cart.order.currency}"

    :crypto.hash(:md5, string) |> Base.encode16(case: :lower)
  end

  def device_session_id_signature(cookie) do
    :crypto.hash(:md5, cookie) |> Base.encode16(case: :lower)
  end
end
