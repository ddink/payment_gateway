defmodule PaymentGateway.RequestBuilderTest do
  use PaymentGateway.CartCase, async: true
  import PaymentGateway.RequestBuilder
  alias PaymentGateway.Gateway.PayuLatam

  describe "build_request_data/1" do
    test "takes a {:payu_latam, :checkout, cart} tuple and
          returns {:ok, :payu_latam, url, json, headers} tuple",
          %{ cart: cart } do
      assert_payu_latam_request_data_built(:checkout, cart)
    end

    test "takes a {:payu_latam, :pay_with_token, cart} tuple and
          returns {:ok, :payu_latam, url, json, headers} tuple",
          %{ cart: cart } do
      assert_payu_latam_request_data_built(:pay_with_token, cart)
    end

    test "takes a {:payu_latam, :tokenize_credit_card, cart} tuple and
          returns {:ok, :payu_latam, url, json, headers} tuple",
         %{ cart: cart } do
      assert_payu_latam_request_data_built(:tokenize_credit_card, cart)
    end

    test "takes a {:payu_latam, :delete_token, cart} tuple and
          returns {:ok, :payu_latam, url, json, headers} tuple",
         %{ cart: cart } do
      assert_payu_latam_request_data_built(:delete_token, cart)
    end

    test "takes a {:payu_latam, :query_tokens, cart} tuple and
          returns {:ok, :payu_latam, url, json, headers} tuple",
         %{ cart: cart } do
      assert_payu_latam_request_data_built(:query_tokens, cart)
    end

    test "error: takes a {:payu_latam, :token_transaction, cart} tuple and
          returns {:ok, :payu_latam, url, error, headers} tuple",
          %{ cart: cart } do
      assert {:ok, :payu_latam, _url, error, _headers, _options} = build_request_data({:payu_latam, :token_transaction, cart})
      assert error == {:error, "unrecognized request type"}
    end
  end

  defp assert_payu_latam_request_data_built(request_type, cart) do
    assert {:ok, :payu_latam, url, json, headers, _options} = build_request_data({:payu_latam, request_type, cart})
    assert url == PayuLatam.api_url()
    assert is_binary(json)
    assert {:ok, _map} = Jason.decode(json)
    assert is_list(headers)
  end

  describe "build_request_json/1" do
    test "success: takes {gateway, cart} tuple and returns JSON encoded binary string", %{ cart: cart } do
      json = build_request_json({:payu_latam, cart})
      assert is_binary(json)
    end
  end

  describe "add_merchant_info/1" do
    test "takes a {:payu_latam, cart} tuple and
          returns a {:payu_latam, cart, map} tuple an initalized map", %{ cart: cart} do
      assert {:payu_latam, _cart, _map} = add_merchant_info({:payu_latam, cart})
    end
  end

  describe "add_order/1" do
    test "takes {:payu_latam, cart, map} tuple and
          returns {:payu_latam, cart, map} tuple with updated map", %{ cart: cart } do
      assert {:payu_latam, _cart, _map} = add_order({:payu_latam, cart, %{}})
    end
  end

  describe "add_buyer/1" do
    test "takes {:payu_latam, cart, map} tuple and
          returns {:payu_latam, cart, map} tuple with updated map",
          %{
            cart: cart,
            order_added_map: map } do
      assert {:payu_latam, _cart, _map} =  add_buyer({:payu_latam, cart, map})
    end
  end

  describe "add_shipping_address/1" do
    test "takes {:payu_latam, cart, map} tuple and
          returns {:payu_latam, cart, map} tuple with updated map",
          %{
            cart: cart,
            order_added_map: order_added_map } do
      assert {:payu_latam, _cart, _map} = add_shipping_address({:payu_latam, cart, order_added_map})
    end
  end

  describe "add_customer/1" do
    test "takes {:payu_latam, cart, map} tuple and
          returns {:payu_latam, cart, map} tuple with updated map",
          %{
            cart: cart,
            order_added_map: map } do
      assert {:payu_latam, _cart, _map} =  add_customer({:payu_latam, cart, map})
    end
  end

  describe "add_payment_method/1" do
    test "takes {:payu_latam, cart, map} tuple
          and returns {:payu_latam, cart, map} tuple with updated map",
          %{
            cart: cart,
            order_added_map: map
          } do
      assert {:payu_latam, _cart, _map} = add_payment_method({:payu_latam, cart, map})
    end
  end

  describe "add_token/1" do
    test "takes {:payu_latam, cart, map} tuple
          and returns {:payu_latam, cart, map} tuple with updated map",
          %{
            cart: cart,
            order_added_map: map
          } do
      assert {:payu_latam, _cart, map} = add_token({:payu_latam, cart, map})
      assert map.transaction.creditCardTokenId == cart.payment_method.cc_token_id
    end
  end

  describe "add_extra_parameters/1" do
    test "takes {:payu_latam, cart, map} tuple
          and returns {cart, map} tuple with updated map",
          %{
            cart: cart,
            order_added_map: map
          } do
      assert {_cart, _map} = add_extra_parameters({:payu_latam, cart, map})
    end
  end

  describe "add_test/1" do
    test "returns {cart, map} tuple with updated map with \"test\"=true
          when in :dev or :test environments", %{ cart: cart } do
      assert {_cart, map} = add_test({cart, %{}})

      assert map[:test] == true
    end

    test "returns {cart, map} tuple with updated map with \"test\"=false
          when not in :dev or :test environments", %{ cart: cart } do
      assert {_cart, map } = add_test({cart, %{}}, :prod)

      assert map[:test] == false
    end
  end
end
