module FifthGearIntegration
  class Shipment < Base
    def get!
      options = {
        "Request" => nil,
        "FromDate" => FifthGear::Helper.dotnet_date_contract("2000-01-03T17:29:15.219Z"),
        "ToDate" => FifthGear::Helper.dotnet_date_contract("2014-08-14T17:29:15.219Z"),
        "StartRange" => 1,
        "EndRange" => 25
      }

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
  end
end
