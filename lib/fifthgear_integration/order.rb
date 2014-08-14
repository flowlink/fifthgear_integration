module FifthGearIntegration
  class Order < Base
    attr_reader :order_payload, :billing_address_payload, :shipping_address_payload

    def initialize(config, payload = {})
      super config, payload

      @order_payload = payload[:order] || {}
      @billing_address_payload = order_payload[:billing_address] || {}
      @shipping_address_payload = order_payload[:shipping_address] || {}
    end

    def post!
      response = FifthGear.cart_submit options

      if response["Errors"].blank? && response["Response"]
        {
          receipt: response["Response"]["OrderReceipt"],
          status: response["Response"]["OrderStatus"]
        }
      else
        raise response["Errors"].inspect
      end
    end

    # NOTE need to map the country code and possibly state code as well
    def options
      {
        "Request" => {
          "BillingAddress" => billing_address,
          "Charges" => [
            {
              "Amount" => order_payload[:totals][:shipping] || 0,
              "ChargeCode" => "Shipping Charges"
            }
          ],
          "CountryCode" => 231,
          "CurrencyCode" => 154,
          "Customer" => customer,
          "Discounts" => [],
          "Items" => items,
          "OrderType" => "internet",
          "OrderDate" => Helper.dotnet_date_contract(order_payload[:placed_on]),
          "OrderMessage" => "",
          "OrderReferenceNumber" => order_payload[:id],
          "Payment" => payment,
          "ShipTos" => shipping_info,
          "Source" => "",
          "SourceCode" => ""
        }
      }
    end

    # NOTE need to map the country code and possibly state code as well
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
        "Email" => order_payload[:email]
      }
    end

    # NOTE what is LineNumber?
    # NOTE Shipto > Ships to the first index of the shiptos array
    def items
      order_payload[:line_items].map do |item|
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

    # NOTE need to map the country code and possibly state code as well
    # NOTE Validate ShippingMethodCode and raise if it's not in the valid list
    # (build that valid list in a constant?)
    #
    # Some shipping codes for web imports:
    #
    #   Next Day > FDXOS
    #   2nd Day Delivery > FDX2D
    #   Ground > FDXGND
    #
    def shipping_info
      [
        {
          # "CarrierAccountNumber" => "",
          # "ExternalShipCode" => "",
          "Recipient" => {
            "FirstName" => shipping_address_payload[:firstname],
            "LastName" => shipping_address_payload[:lastname],
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
          "ShippingMethodCode" => order_payload[:shipping_method] || "FDXOS"
        }
      ]
    end

    # Assume payments are processed on storefront or somewhere else
    # therefore not cash / credit card payments here
    def payment
      amount = order_payload[:payments].map { |p| p[:amount] }.reduce(:+) || 0
      { "WireTransferPayment" => { 'Amount' => amount } }
    end
  end
end
