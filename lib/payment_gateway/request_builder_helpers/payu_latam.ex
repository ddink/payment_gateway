defmodule PaymentGateway.RequestBuilderHelpers.PayuLatam do
  defp test_merchant_api_key do
    Application.fetch_env!(:payment_gateway, :test_merchant_api_key)
  end

  defp test_merchant_api_login do
    Application.fetch_env!(:payment_gateway, :test_merchant_api_login)
  end

  defp prod_merchant_api_key do
    Application.fetch_env!(:payment_gateway, :prod_merchant_api_key)
  end

  defp prod_merchant_api_login do
    Application.fetch_env!(:payment_gateway, :prod_merchant_api_login)
  end

  defp test_merchant_account_id do
    Application.fetch_env!(:payment_gateway, :test_merchant_account_id)
  end

  defp prod_merchant_account_id do
    Application.fetch_env!(:payment_gateway, :prod_merchant_account_id)
  end

  def merchant_api_key(env \\ Mix.env()) when is_atom(env) do
    if Enum.member?([:dev, :test], env) do
      test_merchant_api_key()
    else
      prod_merchant_api_key()
    end
  end

  def merchant_api_login(env \\ Mix.env()) when is_atom(env) do
    if Enum.member?([:dev, :test], env) do
      test_merchant_api_login()
    else
      prod_merchant_api_login()
    end
  end

  def merchant_account_id(env \\ Mix.env()) when is_atom(env) do
    if Enum.member?([:dev, :test], env) do
      test_merchant_account_id()
    else
      prod_merchant_account_id()
    end
  end
end
