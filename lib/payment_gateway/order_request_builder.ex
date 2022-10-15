defmodule PaymentGateway.OrderRequestBuilder do
  alias PaymentGateway.Gateway.PayuLatam

  def build_request_data({gateway, _cart} = order_data) do
    request_body = build_request_json(order_data)
    url = api_url(gateway)
    headers = request_headers(gateway)

    {:ok, gateway, url, request_body, headers}
  end

  def build_request_json(order_data) do
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

  def encode({_cart, map}) do
    Jason.encode!(map)
  end

  defp api_url(:payu_latam), do: PayuLatam.api_url()

  defp request_headers(:payu_latam), do: PayuLatam.request_headers()
end
