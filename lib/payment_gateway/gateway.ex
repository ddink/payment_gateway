defmodule PaymentGateway.Gateway do
  alias PaymentGateway.Gateway.PayuLatam

  def send_api_call({:ok, :payu_latam, url, body}) do
    {:ok, response} = HTTPoison.post(url, body, PayuLatam.request_headers())
    {:payu_latam, response}
  end
  def send_api_call({:error, _reason} = error), do: error

  def handle_transaction_response({:payu_latam, %HTTPoison.Response{} = response}) do
    {:ok, json} = Jason.decode(response.body)
    case json["code"] do
      "SUCCESS" ->
        {:ok, json}
      "ERROR" ->
        {:error, "Unsuccessful transaction call to gateway api. Please try again in a few minutes."}
    end
  end
end
