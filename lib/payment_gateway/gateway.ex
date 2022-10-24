defmodule PaymentGateway.Gateway do
  def send_api_call({:ok, :payu_latam, url, body, headers}) do
    case HTTPoison.post(url, body, headers) do
      {:ok, response} ->
        {:payu_latam, response}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
  def send_api_call({:error, _reason} = error), do: error

  def handle_transaction_response({:payu_latam, %HTTPoison.Response{} = response}) do
    {:ok, response_body} = Jason.decode(response.body)
    case response_body["code"] do
      "SUCCESS" ->
        {:ok, response_body}
      "ERROR" ->
        {:error, "The transaction call to the gateway's api was unsuccessful. Please try again in a few minutes."}
    end
  end
  def handle_transaction_response({:error, :timeout}) do
    {:error, "The transaction call to the gateway's api timed out. Please try again shortly."}
  end
end
