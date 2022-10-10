defmodule PaymentGateway.CartParser do

  @payu_latam_countries ["CO", "BR", "PA", "CL", "PE", "AR", "MX"]
  import PaymentGateway.OrderRequestBuilder

  def parse({:payu_latam, _cart} = order_data) do
    # TODO: handle incomplete cart error ahead of pipeline
    build_request_data(order_data)
  end
  def parse({:error, _reason} = error), do: error
  def parse({_gateway, _cart}), do: {:error, "unrecognized gateway"}

  def select_gateway(%{ payment_country: country } = cart) do
    case Enum.member?(@payu_latam_countries, country) do
      true ->
        {:payu_latam, cart}
      _ ->
        {:error, "no support for non Payu Latam countries atm"}
    end
  end
end
