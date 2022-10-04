defmodule PaymentGatewayTest do
  use ExUnit.Case
  doctest PaymentGateway

  describe "send_api_call/1" do
    test "makes POST request to selected payment gateway's api" do
      # how to test this:
      # 1) test against HTTP response
      # 2) test against a mock (or double--can't remember which is whic)
    end
  end

  describe "handle_transaction_response/1" do
    test "persists transaction response to order schema's respective record"

    test "sends email based on response code w/ relevant messages & reasons"
  end
end
