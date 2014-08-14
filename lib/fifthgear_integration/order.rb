module FifthGearIntegration
  class Order
    attr_reader :order_payload, :billing_address_payload, :shipping_address_payload

    def initialize(config, payload = {})
      super config, payload
      @order_payload = payload[:order]
      @billing_address_payload = order[:billing_address] || {}
      @shipping_address_payload = order[:shipping_address] || {}
    end

    def post!
      FifthGear.cart_submit options
    end

    def options
      {
        "Request" => {
          "BillingAddress" => billing_address
          "Charges" => [
            {
              "Amount" => order[:totals][:shipping],
              "ChargeCode" => "Shipping Charges"
            }
          ],
          "CountryCode" => 231,
          "CurrencyCode" => 154,
          "Customer" => customer,
          "Discounts" => [],
          "Items" => items
          "OrderType" => "internet",
          "OrderDate" => "/Date(1383312895000-0500)/",
          "OrderMessage" => "",
          "OrderReferenceNumber" => order[:id],
          "Payment" => payment,
          "ShipTos" => shipping_info
          "Source" => "",
          "SourceCode" => ""
        }
      }
    end

    def billing_address
      {
        "Address1" => billing_address_payload[:address1],
        "Address2" => billing_address_payload[:address2],
        "City" => billing_address_payload[:city],
        "CountryCode" => 231,
        "Email" => nil,
        "Fax" => "",
        "IsGiftAddress" => false,
        "Organization" => nil,
        "PhoneNumber" => billing_address_payload[:phone],
        "PostalCode" => billing_address_payload[:zipcode],
        "StateOrProvinceCode" => 23
      }
    end

    def customer
      {
        "CustomerNumber" => "",
        "FirstName" => billing_address_payload[:firstname],
        "LastName" => billing_address_payload[:lastname],
        "MiddleName" => "",
        "RefCustomerNumber" => "",
        "Email" => order[:email]
      },
    end

    def items
      order[:line_items].map do |item|
        {
          "ShipTo" => 1,
          "Amount" => item[:price],
          "ItemNumber" => item[:product_id],
          "Quantity" => item[:quantity],
          "Discounts" => [],
          "ParentLineNumber" => 0,
          "GroupName" => nil,
          "LineNumber" => 1,
          "Comments" => nil
        }
      end
    end

    def shipping_info
      [
        {
          "CarrierAccountNumber" => "",
          "ExternalShipCode" => "FXG",
          "Recipient" => {
            "FirstName" => "Bob",
            "LastName" => "Van Der Konkle",
            "MiddleName" => ""
          },
          "ShipLineID" => 1,
          "ShippingAddress" => {
            "Address1" => shipping_address_payload[:address1],
            "Address2" => shipping_address_payload[:address2],
            "City" => shipping_address_payload[:city],
            "CountryCode" => 231,
            "Email" => nil,
            "Fax" => "",
            "IsGiftAddress" => false,
            "Organization" => nil,
            "PhoneNumber" => shipping_address_payload[:phone],
            "PostalCode" => shipping_address_payload[:zipcode],
            "StateOrProvinceCode" => 23
          },
          "ShippingMethodCode" => "XC"
        }
      ]
    end

    def payment
      {
        "IsOnAccountPayment" => "false",
        "RedeemablePayments" => [],
        "CashPayment" => {
          "Amount" => 68,
          "ChequeNumber" => 10001,
          "ChequeDate" => "/Date(1383312895000-0500)/"
        },
        "CreditCardPayments" => [
          {
            "HolderName" => "Bob Van Der Konkle",
            "AddressZip" => "46268",
            "AuthorizationAmount" => 10000,
            "CVV" => 123,
            "ExpirationMonth" => 4,
            "ExpirationYear" => 2014,
            "IsAuthorizationAmountSpecified" => true,
            "AuthorizationCode" => nil,
            "AuthorizationProcessor" => "Authorize.net",
            "OrderReferenceNumber" => nil,
            "TransactionReferenceNumber" => nil
          }
        ]
      }
    end
  end
end
