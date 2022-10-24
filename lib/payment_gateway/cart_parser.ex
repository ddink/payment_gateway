defmodule PaymentGateway.CartParser do
  @payu_latam_countries ["CO", "BR", "PA", "CL", "PE", "AR", "MX"]
  import PaymentGateway.RequestBuilder

  def parse({:payu_latam, _request_type, _cart} = order_data) do
    build_request_data(order_data)
  end
  def parse({:error, _reason} = error), do: error
  def parse({_gateway, _cart}), do: {:error, "unrecognized gateway"}

  def select_gateway({request_type, cart}) do
    case Enum.member?(@payu_latam_countries, cart.order.payment_country) do
      true ->
        {:payu_latam, request_type, cart}
      _ ->
        {:error, "There's no support for non Payu Latam countries at the moment."}
    end
  end
end
