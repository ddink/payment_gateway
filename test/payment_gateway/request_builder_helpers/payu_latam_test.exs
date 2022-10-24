defmodule PaymentGateway.RequestBuilderHelpers.PayuLatamTest do
  use ExUnit.Case

  import PaymentGateway.RequestBuilderHelpers.PayuLatam

  describe "merchant_api_key/1" do
    test "success: returns payu latam's test merchant api key if in the dev or test environments" do
      assert merchant_api_key(:dev) == Application.get_env(:payment_gateway, :test_merchant_api_key)
      assert merchant_api_key(:test) == Application.get_env(:payment_gateway, :test_merchant_api_key)
    end

    test "success: returns payu latam's prod merchant api key if in prod environment" do
      assert merchant_api_key(:prod) == Application.get_env(:payment_gateway, :prod_merchant_api_key)
    end
  end

  describe "merchant_api_login/1" do
    test "success: returns payu latam's test merchant api login if in the dev or test environments" do
      assert merchant_api_login(:dev) == Application.get_env(:payment_gateway, :test_merchant_api_login)
      assert merchant_api_login(:test) == Application.get_env(:payment_gateway, :test_merchant_api_login)
    end

    test "success: returns payu latam's prod merchant api login if in prod environment" do
      assert merchant_api_login(:prod) == Application.get_env(:payment_gateway, :prod_merchant_api_login)
    end
  end

  describe "merchant_account_id/1" do
    test "success: returns payu latam's test merchant account id if in the dev or test environments" do
      assert merchant_account_id(:dev) == Application.get_env(:payment_gateway, :test_merchant_account_id)
      assert merchant_account_id(:test) == Application.get_env(:payment_gateway, :test_merchant_account_id)
    end

    test "success: returns payu latam's prod merchant account id if in prod environment" do
      assert merchant_account_id(:prod) == Application.get_env(:payment_gateway, :prod_merchant_account_id)
    end
  end
end
