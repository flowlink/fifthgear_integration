class FifthGear
  include HTTParty

  class << self
    def company_id(id)
      @@company_id = id
    end

    # Returns an array of item inventories. e.g.
    #
    #   [
    #     { "AvailableToPurchaseQuantity"=>0,
    #       "BackorderAllocationQuantity"=>0,
    #       "ExpectedDate"=>nil,
    #       "ExternalItemNumber"=>nil,
    #       "ItemNumber"=>"BDVQ-1.2101G" },
    #     ...
    #   ]
    #
    def inventory_bulk_lookup(options = {})
      response = service "ItemInventoryBulkLookup", options

      if response.code == 200
        response["Response"]["ItemInventories"]
      end
    end

    # Place an Order
    #
    # Returns a 200 both when order is created or when some validation error
    # happened.
    #
    # Successful response example:
    #
    #   {
    #     "OperationRequest": {
    #       "Arguments": null,
    #       "Errors": null,
    #       "HTTPHeaders": null,
    #       "RequestId": null,
    #       "RequestProcessingTime": 722
    #     },
    #     "Response": {
    #       "OrderReceipt": "64a20548-07ca-4c16-8e61-cf70d3b9ac04",
    #       "OrderStatus":"NotYetShipped"
    #     }
    #   }
    #
    # Error response example:
    #
    #   {
    #     "OperationRequest": {
    #       "Arguments": null,
    #       "Errors": [
    #         {
    #           "Code": "10117",
    #           "Message": "Duplicate order : orderNumber: , orderDate: 11\/01\/2013 9:34:55 AM, lastName: Van Der Konkle, middleName: , firstName: Bob"
    #         }
    #       ],
    #       "HTTPHeaders": null,
    #       "RequestId": null,
    #       "RequestProcessingTime": 307
    #     },
    #     "Response": null
    #   }
    #
    def cart_submit(options = {})
      service "CartSubmit", options
    end

    # Return a collection of orders with their statuses
    #
    # Options:
    #
    #   "Request": null,
    #   "FromDate" : /Date(1387721954000-0500)/,
    #   "ToDate" : /Date(1388067628000-0500)/,
    #   "StartRange" : 1,
    #   "EndRange" : 10
    #
    # Response format:
    #
    #   {
    #     "OperationRequest": {
    #       "Arguments": null,
    #       "Errors": null,
    #       "HTTPHeaders": null,
    #       "RequestId": null,
    #       "RequestProcessingTime": 394
    #     },
    #     "Response": {
    #       "Statuses": [],
    #       "TotalOrderResults": 0
    #     }
    #   }
    #
    def order_status_bulk_lookup(options = {})
      response = service "OrderStatusBulkLookup", options

      if response.code == 200 && hash = response["Response"]
        { orders: hash["Statuses"], count: hash["TotalOrderResults"] }
      end
    end

    def service(name, options = {})
      post(
        "/#{name}",
        headers: { 'Content-Type' => 'text/json' },
        body: { 'CompanyId' => @@company_id }.merge(options).to_json
      )
    end
  end

  class Helper
    class << self
      # All dates need to be passed in the .NET serialized date format
      #
      # See http://stackoverflow.com/questions/17315394/how-to-format-a-php-date-in-net-datacontractjsonserializer-format
      # for reference where logic was taken
      #
      # It basically consists of a string with /Date(UnixTimestamp+UTCOffset)/
      #
      # Here we consider all dates are in UTC hence the +0000
      def dotnet_date_contract(date_string)
        time = Time.parse date_string
        "/Date(#{time.to_i * 1000}+0000)/"
      end
    end
  end
end
