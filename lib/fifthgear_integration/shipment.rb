require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/numeric/time'

module FifthGearIntegration
  class Shipment < Base
    def get!
      options = {
        "Request" => nil,
        "FromDate" => from_date,
        "ToDate" => to_date
      }

      if config[:fifthgear_startrange].present? && config[:fifthgear_endrange].present?
        options.merge!({
          startRange: config[:fifthgear_startrange].to_i,
          endRange: config[:fifthgear_endrange].to_i
        })
      end

      build_shipments FifthGear.order_status_bulk_lookup(options)
    end

    def build_shipments(orders = [])
      orders.map do |order|
        order["ShipmentStatus"].map do |shipment|
          {
            id: shipment["ShipmentNumber"],
            order_id: order["OrderNumber"],
            status: shipment["Status"],
            shipped_at: order["DateShipped"],
            items: []
          }
        end
      end
    end

    def from_date
      number = if config[:fifthgear_orders_range].present?
                 config[:fifthgear_orders_range].to_i
               else
                 30
               end

      FifthGear::Helper.dotnet_date_contract number.days.ago.utc
    end

    def to_date
      FifthGear::Helper.dotnet_date_contract Time.now.utc
    end
  end
end
