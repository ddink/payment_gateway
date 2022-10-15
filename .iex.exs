alias PaymentGateway.OrderRequestBuilder
alias PaymentGateway.Gateway.PayuLatam

cart = %{
  total_transaction_price: 65_000,
  tax_price: 10_000,
  order_price: 55_000,
  currency: "COP",
  payment_installments: 1,
  payment_method: "VISA",
  payment_country: "CO",
  language: "en",
  cookie: "pt1t38347bs6jc9ruv2ecpv7o2",
  browser_user_agent: "Mozilla/5.0 (Windows NT 5.1; rv:18.0) Gecko/20100101 Firefox/18.0",
  skus: %{
    "1234567890" => 2,
    "0987654321" => 1
  },
  user: %{
    id: 1,
    first_name: "Juan",
    last_name: "Doe",
    email: "jd1978@gmail.com",
    phone_number: "555-123-4567",
    documentation_number: "1234A4567B809K"
  },
  shipping_address: %{
    first_line: "Cr 23 No. 53-50",
    second_line: "5555487",
    city: "Bogotá",
    state: "Bogotá D.C.",
    country: "CO",
    postal_code: "000000",
    phone_number: "555-987-6543"
  },
  purchaser: %{
    first_name: "Santiago",
    last_name: "Ruiz",
    email: "sr1960@gmail.com",
    phone_number: "555-426-9980",
    documentation_number: "987E654V321Z"
  },
  billing_address: %{
    first_line: "Cr 23 No. 53-50",
    second_line: "125544",
    city: "Bogotá",
    state: "Bogotá D.C.",
    country: "CO",
    postal_code: "000000",
    phone_number: "555-756-3126"
  },
  credit_card: %{
    number: "4111111111111111",
    security_code: "321",
    expiration_date: "2030/12",
    name: "Santiago Ruiz"
  }
}

headers = PayuLatam.request_headers()
