defmodule PaymentGateway.RequestBuilder do
  alias PaymentGateway.Gateway.PayuLatam

  def build_request_data({gateway, request_type, _cart} = request_data) when is_atom(request_type) do
    request_body = build_json_by_request_type(request_data)
    url = api_url(gateway)
    headers = request_headers(gateway)

    {:ok, gateway, url, request_body, headers}
  end

  defp api_url(:payu_latam), do: PayuLatam.api_url()

  defp request_headers(:payu_latam), do: PayuLatam.request_headers()

  defp build_json_by_request_type({gateway, request_type, cart}) do
    case request_type do
      :checkout ->
        build_request_json({gateway, cart})
      :tokenize_credit_card ->
        build_tokenize_request_json({gateway, cart})
      :delete_token ->
        build_delete_token_request_json({gateway, cart})
      :query_tokens ->
        build_query_tokens_request_json({gateway, cart})
      :pay_with_token ->
        build_pay_with_token_request_json({gateway, cart})
      _ ->
        {:error, "unrecognized request type"}
    end
  end

  def build_request_json({_gateway, _cart} = order_data) do
    order_data
    |> add_merchant_info
    |> add_order
    |> add_buyer
    |> add_shipping_address
    |> add_payer
    |> add_credit_card
    |> add_extra_parameters
    |> add_test
    |> encode
  end

  defp encode({_cart, map}), do: Jason.encode!(map)

  defp build_tokenize_request_json({:payu_latam, cart}) do
    PayuLatam.tokenize_credit_card(cart)
  end

  defp build_delete_token_request_json({:payu_latam, cart}) do
    PayuLatam.delete_credit_card_token(cart)
  end

  defp build_query_tokens_request_json({:payu_latam, cart}) do
    PayuLatam.query_tokens(cart)
  end

  defp build_pay_with_token_request_json(order_data) do
    order_data
    |> add_merchant_info
    |> add_order
    |> add_buyer
    |> add_shipping_address
    |> add_payer
    |> add_token
    |> add_extra_parameters
    |> add_test
    |> encode
  end

  def add_merchant_info({:payu_latam, cart}), do: PayuLatam.add_merchant_info(cart)

  def add_order({:payu_latam, cart, map}) do
    PayuLatam.add_order({cart, map})
  end

  def add_buyer({:payu_latam, cart, map}) do
    PayuLatam.add_buyer({cart, map})
  end

  def add_shipping_address({:payu_latam, cart, map}) do
    PayuLatam.add_shipping_address({cart, map})
  end

  def add_payer({:payu_latam, cart, map}) do
    PayuLatam.add_payer({cart, map})
  end

  def add_credit_card({:payu_latam, cart, map}) do
    PayuLatam.add_credit_card({cart, map})
  end

  def add_token({:payu_latam, cart, map}) do
    PayuLatam.add_token({cart, map})
  end

  def add_extra_parameters({:payu_latam, cart, map}) do
    PayuLatam.add_extra_parameters({cart, map})
  end

  def add_test({cart, map}, env \\ Mix.env()) when is_atom(env) do
    map = if Enum.member?([:dev, :test], env) do
      Map.put(map, :test, true)
    else
      Map.put(map, :test, false)
    end

    {cart, map}
  end
end
