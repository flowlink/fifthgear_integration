require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/numeric/time'

module FifthGearIntegration
  class Shipment < Base
    def get!
      options = {
        "FromDate" => from_date,
        "ToDate" => to_date
      }

      if config[:fifthgear_startrange].present? && config[:fifthgear_endrange].present?
        options.merge!({
          "StartRange" => config[:fifthgear_startrange].to_i,
          "EndRange" => config[:fifthgear_endrange].to_i
        })
      else
        options.merge!({ "StartRange" => 1, "EndRange" => 1000 })
      end

      build_shipments FifthGear.order_status_bulk_lookup(options)
    end

    # Example object returned by Fifth Gear
    #
    #   {
    #     "DateShipped"=>nil,
    #     "ExternalCustomerNumber"=>"",
    #     "ExternalOrderNumber"=>"R44499454545",
    #     "OrderNumber"=>"Test-ORD-19",
    #     "ShipmentStatus"=>
    #      [{"ShipmentNumber"=>nil,
    #        "Status"=>nil,
    #        "TrackingDetails"=>
    #         {"CarrierURL"=>"",
    #          "TrackingData"=>
    #           [{"ItemName"=>"Energy Suspension 1.2101G",
    #             "ItemNumber"=>"BDVQ-1.2101G",
    #             "LineDateShipped"=>nil,
    #             "LineStatus"=>nil,
    #             "QtyShipped"=>"2.0000",
    #             "TrackingNumber"=>"12312321312312312323"}],
    #          "TrackingUrl"=>"https://www.fedex.com/fedextrack/index.html?tracknumbers=",
    #          "TrackingUrlSeperator"=>""}}],
    #     "Status"=>"Closed",
    #     "TrackingDetails"=>{"CarrierURL"=>nil, "TrackingData"=>[], "TrackingUrl"=>nil, "TrackingUrlSeperator"=>nil}
    #   }
    #
    def build_shipments(orders = [])
      shipments = []
      (orders || []).map do |order|
        order["ShipmentStatus"].each_with_index do |shipment, index|
          shipments << {
            id: order["ExternalOrderNumber"] || shipment["ShipmentNumber"] || "#{order["OrderNumber"]}-#{index}",
            status: shipment["Status"],
            tracking: tracking(shipment["TrackingDetails"]["TrackingData"]),
            shipped_at: order["DateShipped"] || Time.now.utc.iso8601,
            updated_at: order["DateShipped"] || Time.now.utc.iso8601,
            items: build_items(shipment["TrackingDetails"]["TrackingData"]),
            fifthgear_original: shipment
          }
        end
      end

      shipments
    end

    def from_date
      FifthGear::Helper.dotnet_date_contract config[:fifthgear_orders_since]
    end

    def to_date
      FifthGear::Helper.dotnet_date_contract Time.now.utc
    end

    def build_items(items)
      (items || []).map do |item|
        {
          name: item["ItemName"],
          product_id: item["ItemNumber"],
          quantity: item["QtyShipped"]
        }
      end
    end

    def tracking(items)
      item = (items || []).first

      if item.is_a? Hash
        item["TrackingNumber"]
      end
    end
  end
end
