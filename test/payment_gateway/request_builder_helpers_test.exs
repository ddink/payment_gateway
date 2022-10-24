defmodule PaymentGateway.RequestBuilderHelpersTest do
  use ExUnit.Case
  import PaymentGateway.RequestBuilderHelpers

  test "ip_address/0 returns binary string with ip address pattern containing integers" do
    assert [n1, n2, h1, h2] = String.split(ip_address(), ".")
    assert String.to_integer(n1) |> is_integer
    assert String.to_integer(n2) |> is_integer
    assert String.to_integer(h1) |> is_integer
    assert String.to_integer(h2) |> is_integer
  end

  describe "payu_latam_test_account_id/1" do
    test "when given a payu latam country code should return a binary string representing
          a test account id for payu latam gateway's api" do
      assert "CO" |> payu_latam_test_account_id |> is_binary
      assert "BR" |> payu_latam_test_account_id |> is_binary
    end

    test "when given a non-payu latam country code should return nil" do
      assert "US" |> payu_latam_test_account_id |> is_nil
      assert "UK" |> payu_latam_test_account_id |> is_nil
    end
  end
end
