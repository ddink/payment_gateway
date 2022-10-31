defmodule PaymentGateway.GatewayTest do
  use PaymentGateway.CartCase, async: true
  import PaymentGateway.Gateway
  alias PaymentGateway.Gateway.PayuLatam

  @test_api_url "https://sandbox.api.payulatam.com/payments-api/4.0/service.cgi"

  describe "send_request/1" do
    @tag :api_call
    test "success: takes a {:ok, gateway, url, body, headers} tuple and returns a {:ok, response_body} tuple",
      %{ payu_latam_request_body: json} do
        request_data = payu_latam_request_data(json)

        case send_request(request_data) do
          {:error, reason} ->
            assert reason =~ "timed out"
          response ->
            assert {:ok, _response_body} = response
        end
    end
  end

  describe "send_api_call/1" do
    @tag :api_call
    test "success: takes a {:ok, gateway, url, body, headers} tuple and returns a {:payu_latam, %HTTPoison.Response{}}" do
      request_data = payu_latam_request_data("")

      assert {:payu_latam, %HTTPoison.Response{} = response} = send_api_call(request_data)
      assert map = Jason.decode!(response.body)
      assert map["code"] == "ERROR"
    end

    @tag :api_call
    test "success: returns a successful HTTPoison.Response when api call is successful",
      %{ payu_latam_request_body: json} do
      request_data = payu_latam_request_data(json)

      case send_api_call(request_data) do
        {:payu_latam, response} ->
          assert map = Jason.decode!(response.body)
          assert map["code"] == "SUCCESS"
        {:error, message} ->
          assert message == :timeout
      end
    end

    @tag :api_call
    test "error: takes a {:error, reason} tuple and returns the same tuple" do
      assert {:error, "error message"} = send_api_call({:error, "error message"})
    end
  end

  defp payu_latam_request_data(json) do
    {:ok, :payu_latam, @test_api_url, json, PayuLatam.request_headers(), PayuLatam.request_options()}
  end

  describe "handle_transaction_response/1" do
    @tag :api_call
    test "success: receives a {:payu_latam, %HTTPoison.Response{}} tuple and returns {:ok, json_map} tuple when transaction is successful" do
      response = %HTTPoison.Response{
        body: """
        {\"code\":\"SUCCESS\",\"error\":null,\"transactionResponse\":{\"orderId\":2147896070,\"transactionId\":\"a65c2de5-fdbb-4264-9c0c-7ea124cdf9fd\",
        \"state\":\"DECLINED\",\"paymentNetworkResponseCode\":\"15\",\"paymentNetworkResponseErrorMessage\":\"Invalid issuer\",\"trazabilityCode\":\"00006535-00000023202\",
        \"authorizationCode\":null,\"pendingReason\":null,\"responseCode\":\"INVALID_TRANSACTION\",\"errorCode\":null,\"responseMessage\":null,\"transactionDate\":null,
        \"transactionTime\":null,\"operationDate\":1665418818977,\"referenceQuestionnaire\":null,\"extraParameters\":{\"BANK_REFERENCED_CODE\":\"CREDIT\"},
        \"additionalInfo\":{\"paymentNetwork\":\"MOVII\",\"rejectionType\":\"SOFT_DECLINE\",\"responseNetworkMessage\":\"Invalid issuer\",\"travelAgencyAuthorizationCode\":null,
        \"cardType\":\"CREDIT\",\"transactionType\":\"AUTHORIZATION_AND_CAPTURE\"}}}
        """
      }
      assert {:ok, body} = handle_transaction_response({:payu_latam, response})
      assert is_map(body)
    end

    @tag :api_call
    test "error: receives a {:payu_latam, %HTTPoison.Response{}} tuple and returns {:error, reason} tuple when transaction is unsuccessful" do
      response = %HTTPoison.Response{
        body: "{\"code\":\"ERROR\",\"error\":\"Invalid request format\",\"transactionResponse\":null}"
      }
      assert {:error, reason} = handle_transaction_response({:payu_latam, response})
      assert reason == "The transaction call to the gateway's api was unsuccessful. Please try again in a few minutes."
    end

    @tag :api_call
    test "error: receives a {:error, :timeout} tuple and returns {:error, _message} when an api call times out" do
      assert {:error, reason} = handle_transaction_response({:error, :timeout})
      assert reason == "The transaction call to the gateway's api timed out. Please try again shortly."
    end
  end
end
