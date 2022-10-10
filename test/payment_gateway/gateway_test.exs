defmodule PaymentGateway.GatewayTest do
  use PaymentGateway.CartCase, async: true
  import PaymentGateway.Gateway

  @test_api_url "https://sandbox.api.payulatam.com/payments-api/4.0/service.cgi"

  describe "send_api_call/1" do
    test "takes a {:ok, gateway, _, _} tuple and returns a {:payu_latam, %HTTPoison.Response{}}",
          %{ payu_latam_request_body: json } do

      assert {:payu_latam, %HTTPoison.Response{}} = send_api_call({:ok, :payu_latam, @test_api_url, json})
    end

    test "takes a {:error, reason} tuple and returns the same tuple" do
      assert {:error, "error message"} = send_api_call({:error, "error message"})
    end
  end

  describe "handle_transaction_response/1" do
    # TODO: test "receives HTTP.Response struct and returns {:ok, _} tuple when transaction is successful"
    test "receives a {:payu_latam, %HTTPoison.Response{}} tuple and returns {:ok, json_map} tuple when transaction is successful" do
      response = %HTTPoison.Response{
        body: "{\"code\":\"SUCCESS\",\"error\":\"Invalid request format\",\"transactionResponse\":null}"
      }
      assert {:ok, body} = handle_transaction_response({:payu_latam, response})
      assert is_map(body)
    end

    # TODO: test "receives HTTP.Response struct and returns {:error, _} tuple when transaction has an error"
    test "receives a {:payu_latam, %HTTPoison.Response{}} and returns {:error, reason} tuple when transaction is unsuccessful" do
      response = %HTTPoison.Response{
        body: "{\"code\":\"ERROR\",\"error\":\"Invalid request format\",\"transactionResponse\":null}"
      }
      assert {:error, reason} = handle_transaction_response({:payu_latam, response})
      assert reason == "Unsuccessful transaction call to gateway api. Please try again in a few minutes."
    end
  end
end
