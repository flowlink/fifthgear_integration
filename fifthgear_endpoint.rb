require "sinatra"
require "endpoint_base"

require File.expand_path(File.dirname(__FILE__) + '/lib/fifthgear_integration')

class FifthGearEndpoint < EndpointBase::Sinatra::Base
  endpoint_key ENV['ENDPOINT_KEY']

  post "/add_order" do
    order = FifthGearIntegration::Order.new(@config, @payload).post!
    result 200, "Order successfully placed in FifthGear. Receipt #{order[:receipt]}"
  end

  post "/get_inventory" do
    inventories = FifthGearIntegration::Inventory.new(@config, @payload).get!

    inventories.each do |i|
      add_object "inventory", i.merge(id: i[:sku])
    end

    line = if (count = inventories.count) > 0
             "Updating #{count} #{"inventory".pluralize count} record from FifthGear"
           else
             "No inventory found in FifthGear"
           end

    result 200, line
  end

  post "/get_shipments" do
    shipments = FifthGearIntegration::Shipment.new(@config).get!
    result 200
  end
end
