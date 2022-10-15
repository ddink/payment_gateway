defmodule PaymentGateway.OrderRequestBuilderTest do
  use PaymentGateway.CartCase, async: true
  import PaymentGateway.OrderRequestBuilder
  alias PaymentGateway.Gateway.PayuLatam

  describe "build_request_data/1" do
    test "takes a {:payu_latam, cart} tuple and returns {:ok, :payu_latam, url, json} tuple",
          %{ cart: cart } do
      assert {:ok, :payu_latam, url, json, headers} = build_request_data({:payu_latam, cart})
      assert url == PayuLatam.api_url()
      assert is_binary(json)
      assert {:ok, _map} = Jason.decode(json)
      assert is_list(headers)
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

  describe "add_payer/1" do
    test "takes {:payu_latam, cart, map} tuple and
          returns {:payu_latam, cart, map} tuple with updated map",
          %{
            cart: cart,
            order_added_map: map } do
      assert {:payu_latam, _cart, _map} =  add_payer({:payu_latam, cart, map})
    end
  end

  describe "add_credit_card/1" do
    test "takes {:payu_latam, cart, map} tuple
          and returns {:payu_latam, cart, map} tuple with updated map",
          %{
            cart: cart,
            order_added_map: map } do
      assert {:payu_latam, _cart, _map} = add_credit_card({:payu_latam, cart, map})
    end
  end

  describe "add_extra_parameters/1" do
    test "takes {:payu_latam, cart, map} tuple
          and returns {cart, map} tuple with updated map",
          %{
            cart: cart,
            order_added_map: map } do
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
