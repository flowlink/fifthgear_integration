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
      else
      end
    end

    def cart_submit(options = {})
      service "CartSubmit", options
    end

    # Possible options
    #
    #   "Request": {
    #     "FromDate" : /Date(1387721954000-0500)/, # .NET Datetime String
    #     "ToDate" : /Date(1388067628000-0500)/, 
    #     "StartRange" : 1,
    #     "EndRange" : 10
    #   }
    #
    def order_status_bulk_lookup(options = {})
      service "OrderStatusBulkLookup", options
    end

    def service(name, options = {})
      post(
        "/#{name}",
        headers: { 'Content-Type' => 'text/json' },
        body: { 'CompanyId' => @@company_id }.merge(options).to_json
      )
    end
  end
end
