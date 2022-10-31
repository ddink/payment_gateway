defmodule PaymentGateway.Gateway do
  def send_request(request_data) do
    with {_gateway, _body} = response <- send_api_call(request_data),
         {:ok, response_body} <- handle_transaction_response(response) do
      {:ok, response_body}
    else
      error -> error
    end
  end

  def send_api_call({:ok, :payu_latam, url, body, headers, options}) do
    # HTTPoison.post(url, body, headers, hackney: [pool: :payu_latam])
    case HTTPoison.post(url, body, headers, options) do
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
