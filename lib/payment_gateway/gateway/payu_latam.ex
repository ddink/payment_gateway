defmodule PaymentGateway.Gateway.PayuLatam do
  @transaction_command "SUBMIT_TRANSACTION"
  @notify_url "http://www.payu.com/notify"
  @test_api_url "https://sandbox.api.payulatam.com/payments-api/4.0/service.cgi"
  @prod_api_url "https://api.payulatam.com/payments-api/4.0/service.cgi"
  @request_headers [
    {"Host", "sandbox.api.payulatam.com"},
    {"Content-Type", "application/json; charset=utf-8"},
    {"Accept", "application/json"},
    {"Content-Length", "length"}
  ]

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
  import PaymentGateway.RequestBuilderHelpers

  def add_merchant_info(%{language: language} = cart) do
    map = %{
      language: language,
      command: @transaction_command,
      merchant: %{
        apiKey: @merchant_api_key,
        apiLogin: @merchant_api_login
      }
    }

    {:payu_latam, cart, map}
  end
  def add_merchant_info(_cart) do
    {:error, "cart is missing language"}
  end

  def add_transaction_order({%{
    language: language,
    total_transaction_price: total_price,
    tax_price: tax_price,
    order_price: order_price,
    currency: currency
  } = cart, map}) do
    # TODO: create Order for notifyUrl field

    order = %{
      order: %{
        accountId: @merchant_account_id,
        referenceCode: reference_code(cart),
        description: order_description(),
        language: language,
        signature: order_signature(cart),
        notifyUrl: @notify_url,
        additionalValues: %{
          "TX_VALUE" => %{
            value: total_price,
            currency: currency
          },
          "TX_TAX" => %{
            value: tax_price,
            currency: currency
          },
          "TX_TAX_RETURN_BASE" => %{
            value: order_price,
            currency: currency
          }
        }
      }
    }

    map = Map.put(map, :transaction, order)

    {:payu_latam, cart, map}
  end
  def add_transaction_order(_request_data) do
    {:error, "cart missing transaction order data"}
  end

  def add_transaction_buyer({%{
    user: %{
      id: id,
      first_name: first_name,
      last_name: last_name,
      email: email,
      phone_number: user_phone_number,
      documentation_number: documentation_number
    },
    shipping_address: %{
      first_line: first_line,
      second_line: second_line,
      city: city,
      state: state,
      country: country,
      postal_code: postal_code,
      phone_number: shipping_adress_phone_number
    }
  } = cart, map}) do
    buyer = %{
      merchantBuyerId: id,
      fullName: "#{first_name} #{last_name}",
      emailAddress: email,
      contactPhone: user_phone_number,
      dniNumber: documentation_number,
      shippingAddress: %{
        street1: first_line,
        street2: second_line,
        city: city,
        state: state,
        country: country,
        postalCode: postal_code,
        phone: shipping_adress_phone_number
      }
    }

    transaction =
      map
      |> Map.fetch!(:transaction)
      |> Map.put(:buyer, buyer)

    map = Map.put(map, :transaction, transaction)

    {:payu_latam, cart, map}
  end
  def add_transaction_buyer(_request_data) do
    {:error, "cart missing transaction buyer data"}
  end

  def add_transaction_shipping_address({%{
    shipping_address: %{
      first_line: first_line,
      second_line: second_line,
      city: city,
      state: state,
      country: country,
      postal_code: postal_code,
      phone_number: phone_number
    }
  } = cart, map}) do
    shipping_address = %{
      street1: first_line,
      street2: second_line,
      city: city,
      state: state,
      country: country,
      postalCode: postal_code,
      phone: phone_number
    }

    transaction =
      map
      |> Map.fetch!(:transaction)
      |> Map.put(:shippingAddress, shipping_address)

    map = Map.put(map, :transaction, transaction)

    {:payu_latam, cart, map}
  end
  def add_transaction_shipping_address(_request_data) do
    {:error, "cart missing transaction shipping address data"}
  end

  def add_payer({%{
    user: %{
      id: id
    },
    purchaser: %{
      first_name: first_name,
      last_name: last_name,
      email: email,
      phone_number: purchaser_phone_number,
      documentation_number: documentation_number
    },
    billing_address: %{
      first_line: first_line,
      second_line: second_line,
      city: city,
      state: state,
      country: country,
      postal_code: postal_code,
      phone_number: billing_adress_phone_number
    }
  } = cart, map}) do
    payer = %{
      merchantBuyerId: id,
      fullName: "#{first_name} #{last_name}",
      emailAddress: email,
      contactPhone: purchaser_phone_number,
      dniNumber: documentation_number,
      billingAddress: %{
        street1: first_line,
        street2: second_line,
        city: city,
        state: state,
        country: country,
        postalCode: postal_code,
        phone: billing_adress_phone_number
      }
    }

    map = Map.put(map, :payer, payer)

    {:payu_latam, cart, map}
  end
  def add_payer(_request_data) do
    {:error, "cart missing payer data"}
  end

  def add_credit_card({%{
    purchaser: %{
      first_name: first_name,
      last_name: last_name
    },
    credit_card: %{
      number: number,
      security_code: security_code,
      expiration_date: expiration_date
    }
  } = cart, map}) do
    credit_card = %{
      number: number,
      securityCode: security_code,
      expirationDate: expiration_date,
      name: "#{first_name} #{last_name}"
    }

    map = Map.put(map, :creditCard, credit_card)

    {:payu_latam, cart, map}
  end
  def add_credit_card(_request_data) do
    {:error, "cart missing credit card data"}
  end

  def add_extra_parameters({%{
    payment_method: payment_method,
    payment_country: payment_country,
    cookie: cookie,
    browser_user_agent: browser_user_agent
  } = cart, map}) do

    # TODO: add support for extra parameters like quota/payment installments
    # extra_parameters = %{
    #   "INSTALLMENTS_NUMBER": cart.payment_installments
    # }

    map = map
          # |> Map.put(:extraParameters, extra_parameters)
          |> Map.put(:paymentMethod, payment_method)
          |> Map.put(:paymentCountry, payment_country)
          |> Map.put(:deviceSessionId, device_session_id_signature(cookie))
          |> Map.put(:ipAddress, ip_address())
          |> Map.put(:cookie, cookie)
          |> Map.put(:userAgent, browser_user_agent)
          |> add_three_domain_secure_attributes

    # switches to {cart, map} return for OrderRequestBuilder.add_test/2
    {cart, map}
  end
  def add_extra_parameters(_request_data) do
    {:error, "cart missing extra parameters data"}
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

  def api_url(env \\ Mix.env()) when is_atom(env) do
    if Enum.member?([:dev, :test], env) do
      @test_api_url
    else
      @prod_api_url
    end
  end

  def request_headers(), do: HTTPoison.process_request_headers(@request_headers)
end
