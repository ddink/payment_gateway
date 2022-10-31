defmodule PaymentGateway.Gateway.PayuLatam.Tokens do
  @create_token_command "CREATE_TOKEN"
  @delete_token_command "REMOVE_TOKEN"
  @query_tokens_command "GET_TOKENS"

  import PaymentGateway.RequestBuilderHelpers.PayuLatam
  use Timex

  def tokenize_credit_card(user, payment_method, language) do
    %{
      language: language,
      command: @create_token_command,
      merchant: %{
         apiLogin: merchant_api_login(),
         apiKey: merchant_api_key()
      },
      creditCardToken: %{
         payerId: user.id,
         name: payment_method.cc_name,
         identificationNumber: user.documentation_number,
         paymentMethod: payment_method.name,
         number: payment_method.cc_number,
         expirationDate: payment_method.cc_expiration_date
      }
    } |> encode
  end
  def tokenize_credit_card(%{
    language: language,
    user: %{
      id: id,
      documentation_number: documentation_number
    },
    payment_method: %{
      cc_number: number,
      cc_expiration_date: expiration_date,
      cc_name: name,
      name: payment_method
    }
  } = _cart) do
    %{
      language: language,
      command: @create_token_command,
      merchant: %{
         apiLogin: merchant_api_login(),
         apiKey: merchant_api_key()
      },
      creditCardToken: %{
         payerId: id,
         name: name,
         identificationNumber: documentation_number,
         paymentMethod: payment_method,
         number: number,
         expirationDate: expiration_date
      }
    } |> encode
  end
  def tokenize_credit_card(_request_data) do
    {:error, "missing request data needed to tokenize credit card"}
  end

  def delete_credit_card_token(user, payment_method, language) do
    %{
      language: language,
      command: @delete_token_command,
      merchant: %{
        apiLogin: merchant_api_login(),
        apiKey: merchant_api_key()
      },
      removeCreditCardToken: %{
        payerId: user.id,
        creditCardTokenId: payment_method.cc_token_id
      }
    } |> encode
  end
  def delete_credit_card_token(%{
    language: language,
    user: %{ id: id },
    payment_method: %{ cc_token_id: token_id }
  } = _cart) do
    %{
      language: language,
      command: @delete_token_command,
      merchant: %{
        apiLogin: merchant_api_login(),
        apiKey: merchant_api_key()
      },
      removeCreditCardToken: %{
        payerId: id,
        creditCardTokenId: token_id
     }
    } |> encode
  end
  def delete_credit_card_token(_request_data) do
    {:error, "missing request data needed to delete credit card token"}
  end

  def query_tokens(user, language) do
    %{
      language: language,
      command: @query_tokens_command,
      merchant: %{
        apiLogin: merchant_api_login(),
        apiKey: merchant_api_key()
      },
      creditCardTokenInformation: %{
        creditCardTokenId: user.default_credit_card_token_id
      }
    } |> encode
  end
  def query_tokens(%{
    language: language,
    payment_method: %{ cc_token_id: token_id }
  } = _cart) do
    %{
      language: language,
      command: @query_tokens_command,
      merchant: %{
        apiLogin: merchant_api_login(),
        apiKey: merchant_api_key()
      },
      creditCardTokenInformation: %{
        creditCardTokenId: token_id
      }
    } |> encode
  end
  def query_tokens(%{
    language: language,
    user: %{ inserted_at: inserted_at }
  } = _cart) do
    %{
      language: language,
      command: @query_tokens_command,
      merchant: %{
        apiLogin: merchant_api_login(),
        apiKey: merchant_api_key()
      },
      creditCardTokenInformation: %{
        startDate: Timex.format!(inserted_at, "%FT%T%:z", :strftime),
        endDate: Timex.format!(Timex.now(), "%FT%T%:z", :strftime)
      }
     } |> encode
  end
  def query_tokens(_request_data) do
    {:error, "missing request data needed to query credit card tokens"}
  end

  defp encode(map), do: Jason.encode!(map)
end
