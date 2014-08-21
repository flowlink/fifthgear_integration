require "sinatra"
require "endpoint_base"

require File.expand_path(File.dirname(__FILE__) + '/lib/fifthgear_integration')

class FifthGearEndpoint < EndpointBase::Sinatra::Base
  endpoint_key ENV['ENDPOINT_KEY']

  Honeybadger.configure do |config|
    config.api_key = ENV['HONEYBADGER_KEY']
    config.environment_name = ENV['RACK_ENV']
  end if ENV['HONEYBADGER_KEY'].present?

  post "/add_order" do
    order = FifthGearIntegration::Order.new(@config, @payload).post!
    result 200, "Order successfully placed in Fifth Gear. Receipt #{order[:receipt]}"
  end

  post "/get_inventory" do
    inventories = FifthGearIntegration::Inventory.new(@config, @payload).get!

    inventories.each do |i|
      add_object "inventory", i.merge(id: i[:sku])
    end

    line = if (count = inventories.count) > 0
             "Updating #{count} #{"inventory".pluralize count} record from Fifth Gear"
           else
             "No inventory found in Fifth Gear"
           end

    result 200, line
  end

  post "/get_shipments" do
    shipments = FifthGearIntegration::Shipment.new(@config).get!
    shipments.each { |s| add_object "shipment", s }

    line = if (count = shipments.count) > 0
             "Updating #{count} #{"shipment".pluralize count} record from Fifth Gear"
           else
             "No shipment update found in Fifth Gear"
           end
    
    add_parameter "fifthgear_orders_since", Time.now.utc.iso8601

    result 200, line
  end
end
