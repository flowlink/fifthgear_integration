module FifthGearIntegration
  class Inventory < Base
    attr_reader :inventory

    def initialize(config, payload = {})
      super config, payload
      @inventory = payload[:inventory] || {}
    end

    def get!
      if inventory[:sku].present?
        item = FifthGear.item_inventory_lookup({ Request: inventory[:sku] })
        [item]
      else
        # Range is to avoid getting +3000 items back for the time being
        options = {
          Request: {
            startRange: 1,
            endRange: 3
          }
        }

        FifthGear.item_inventory_bulk_lookup options
      end
    end
  end
end
