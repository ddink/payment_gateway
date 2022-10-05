defmodule PaymentGateway.OrderRequestBuilder do
  @transaction_command "SUBMIT_TRANSACTION"
  @notify_url "http://www.payu.com/notify"

  # attributes that will be determined by client

  # 3-D secure attributes
  @embedded false
  @eci "01"
  @cavv "AOvG5rV058/iAAWhssPUAAADFA=="
  @xid "Nmp3VFdWMlEwZ05pWGN3SGo4TDA="
  @directory_server_transaction_id "00000-70000b-5cc9-0000-000000000cb"

  # to be stored as environment/config variables
  @merchant_api_key "4Vj8eK4rloUd272L48hsrarnUA"
  @merchant_api_login "pRRXKOl8ikMmt9u"
  @merchant_account_id "512321"

  import PaymentGateway.SignatureEncoder

  def add_merchant_info(cart) do
    map = %{
      language: cart.language,
      command: @transaction_command,
      merchant: %{
        apiKey: @merchant_api_key,
        apiLogin: @merchant_api_login
      }
    }

    {cart, map}
  end

  def add_transaction_order({cart, map}) do
    # TODO: create Order for notifyUrl field

    order = %{
      order: %{
        accountId: @merchant_account_id,
        referenceCode: reference_code(cart),
        description: order_description(),
        language: cart.language,
        signature: order_signature(cart),
        notifyUrl: @notify_url,
        additionalValues: %{
          "TX_VALUE" => %{
            value: cart.total_transaction_price,
            currency: cart.currency
          },
          "TX_TAX" => %{
            value: cart.tax_price,
            currency: cart.currency
          },
          "TX_TAX_RETURN_BASE" => %{
            value: cart.order_price,
            currency: cart.currency
          }
        }
      }
    }

    map = Map.put(map, :transaction, order)

    {cart, map}
  end

  def add_transaction_buyer({cart, map}) do
    buyer = %{
      merchantBuyerId: cart.user.id,
      fullName: "#{cart.user.first_name} #{cart.user.last_name}",
      emailAddress: cart.user.email,
      contactPhone: cart.user.phone_number,
      dniNumber: cart.user.documentation_number,
      shippingAddress: %{
        street1: cart.shipping_address.first_line,
        street2: cart.shipping_address.second_line,
        city: cart.shipping_address.city,
        state: cart.shipping_address.state,
        country: cart.shipping_address.country,
        postalCode: cart.shipping_address.postal_code,
        phone: cart.shipping_address.phone_number
      }
    }

    transaction =
      map
      |> Map.fetch!(:transaction)
      |> Map.put(:buyer, buyer)

    map = Map.put(map, :transaction, transaction)

    {cart, map}
  end

  def add_transaction_shipping_address({cart, map}) do
    shipping_address = %{
      street1: cart.shipping_address.first_line,
      street2: cart.shipping_address.second_line,
      city: cart.shipping_address.city,
      state: cart.shipping_address.state,
      country: cart.shipping_address.country,
      postalCode: cart.shipping_address.postal_code,
      phone: cart.shipping_address.phone_number
    }

    transaction =
      map
      |> Map.fetch!(:transaction)
      |> Map.put(:shippingAddress, shipping_address)

    map = Map.put(map, :transaction, transaction)

    {cart, map}
  end

  def add_payer({cart, map}) do
    payer = %{
      merchantBuyerId: cart.user.id,
      fullName: "#{cart.purchaser.first_name} #{cart.purchaser.last_name}",
      emailAddress: cart.purchaser.email,
      contactPhone: cart.purchaser.phone_number,
      dniNumber: cart.purchaser.documentation_number,
      billingAddress: %{
        street1: cart.billing_address.first_line,
        street2: cart.billing_address.second_line,
        city: cart.billing_address.city,
        state: cart.billing_address.state,
        country: cart.billing_address.country,
        postalCode: cart.billing_address.postal_code,
        phone: cart.billing_address.phone_number
      }
    }

    map = Map.put(map, :payer, payer)

    {cart, map}
  end

  def add_credit_card({cart, map}) do
    credit_card = %{
      number: cart.credit_card.number,
      securityCode: cart.credit_card.security_code,
      expirationDate: cart.credit_card.expiration_date,
      name: "#{cart.purchaser.first_name} #{cart.purchaser.last_name}"
    }

    map = Map.put(map, :creditCard, credit_card)

    {cart, map}
  end

  def add_extra_parameters({cart, map}) do
    extra_parameters = %{
      "INSTALLMENTS_NUMBER": cart.payment_installments
    }

    map = map
          |> Map.put(:extraParameters, extra_parameters)
          |> Map.put(:paymentMethod, cart.payment_method)
          |> Map.put(:paymentCountry, cart.payment_country)
          |> Map.put(:deviceSessionId, device_session_id_signature(cart.cookie))
          |> Map.put(:ipAddress, ip_address())
          |> Map.put(:cookie, cart.cookie)
          |> Map.put(:userAgent, cart.browser_user_agent)
          |> add_three_domain_secure_attributes

    {cart, map}
  end

  def add_test({cart, map}, env \\ Mix.env()) when is_atom(env) do
    map = if Enum.member?([:dev, :test], env) do
      Map.put(map, :test, true)
    else
      Map.put(map, :test, false)
    end

    {cart, map}
  end

  def encode({_cart, map}) do
    Jason.encode!(map)
  end

  defp ip_address() do
    {:ok, ifs} = :inet.getif()
    ips = Enum.map(ifs, fn {ip, _broadaddr, _mask} -> ip end)

    {n1, n2, h1, h2} = ips |> List.first

    "#{n1}.#{n2}.#{h1}.#{h2}"
  end

  defp add_three_domain_secure_attributes(map) do
    three_domain_secure = %{
      embedded: @embedded,
      eci: @eci,
      cavv: @cavv,
      xid: @xid,
      directoryServerTransactionId: @directory_server_transaction_id
    }

    Map.put(map, :threeDomainSecure, three_domain_secure)
  end
end
