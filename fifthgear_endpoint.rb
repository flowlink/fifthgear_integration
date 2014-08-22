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
    inventory = FifthGearIntegration::Inventory.new(@config, @payload)
    inventories = inventory.get!

    inventories.each { |i| add_object "inventory", i.merge(id: i[:sku]) }

    unless @payload[:inventory] && @payload[:inventory][:sku]
      add_parameter "fifthgear_startrange", inventory.next_start
      add_parameter "fifthgear_endrange", inventory.next_end
    end

    if (count = inventories.count) > 0
      result 200, "Updating #{count} #{"inventory".pluralize count} record from Fifth Gear"
    else
      result 200
    end
  end

  post "/get_shipments" do
    shipments = FifthGearIntegration::Shipment.new(@config).get!
    shipments.each { |s| add_object "shipment", s }

    add_parameter "fifthgear_orders_since", Time.now.utc.iso8601

    if (count = shipments.count) > 0
      result 200, "Updating #{count} #{"shipment".pluralize count} record from Fifth Gear"
    else
      result 200
    end
  end
end
