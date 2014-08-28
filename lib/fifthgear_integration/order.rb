module FifthGearIntegration
  class Order < Base
    attr_reader :order_payload, :billing_address_payload, :shipping_address_payload
    
    @@country_codes = JSON.parse IO.read(File.join(__dir__, "../fifthgear/country_codes.json"))
    @@state_codes = JSON.parse IO.read(File.join(__dir__, "../fifthgear/state_codes.json"))
    @@ship_codes = JSON.parse IO.read(File.join(__dir__, "../fifthgear/ship_codes.json"))

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
          "CountryCode" => country_code(billing_address_payload[:country]),
          "CurrencyCode" => order_payload[:country_code] || 154,
          "Customer" => customer,
          "Discounts" => [],
          "Items" => items,
          "OrderType" => "internet",
          "OrderDate" => FifthGear::Helper.dotnet_date_contract(order_payload[:placed_on]),
          "OrderMessage" => "",
          "OrderReferenceNumber" => order_payload[:id],
          "IsWholesaleDirect" => order_payload[:is_whole_sale_direct] || false,
          "Payment" => payment,
          "ShipTos" => shipping_info,
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
        "CountryCode" => country_code(billing_address_payload[:country]),
        "Email" => nil,
        "Fax" => "",
        "IsGiftAddress" => false,
        "Organization" => nil,
        "PhoneNumber" => billing_address_payload[:phone],
        "PostalCode" => billing_address_payload[:zipcode],
        "StateOrProvinceCode" => state_code(shipping_address_payload[:state])
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

    # NOTE Shipto > the first index of the shiptos array
    def items
      order_payload[:line_items].each_with_index.map do |item, index|
        {
          "ShipTo" => 1,
          "Amount" => item[:price],
          "ItemNumber" => item[:product_id] || item[:sku],
          "Quantity" => item[:quantity],
          "Discounts" => [],
          "ParentLineNumber" => 0,
          "GroupName" => nil,
          "LineNumber" => index + 1,
          "Comments" => nil
        }
      end
    end

    def shipping_info
      [
        {
          "CarrierAccountNumber" => order_payload[:carrier_account_number] || "",
          "ExternalShipCode" => ship_code(order_payload[:external_ship_code]),
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
            "CountryCode" => country_code(shipping_address_payload[:country]),
            "Email" => nil,
            "Fax" => "",
            "IsGiftAddress" => false,
            "Organization" => nil,
            "PhoneNumber" => shipping_address_payload[:phone],
            "PostalCode" => shipping_address_payload[:zipcode],
            "StateOrProvinceCode" => state_code(shipping_address_payload[:state])
          },
          "ShippingMethodCode" => ""
        }
      ]
    end

    # Assume payments are processed on storefront or somewhere else
    # therefore not cash / credit card payments here
    def payment
      amount = order_payload[:payments].map { |p| p[:amount] }.reduce(:+) || 0
      { "WireTransferPayment" => { 'Amount' => amount } }
    end

    # Default to USA code if no country code is found
    def country_code(country)
      if @@country_codes[country]
        @@country_codes[country]["code"]
      else
        231
      end
    end

    def state_code(state)
      if match = @@state_codes[state]
        match["code"]
      elsif match = @@state_codes.values.find { |h| h["name"] == state }
        match["code"]
      else
        0 # Unknown
      end
    end

    def ship_code(shipping_method)
      if shipping_method.present? && !@@ship_codes.values.include?(shipping_method)
        raise InvalidShipCodeError, "Invalid Shipping Code provided. Please provide a valid ship code"
      else
        shipping_method || "FDXOS" # Next Day
      end
    end
  end
end
