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
        options = {}

        if config[:fifthgear_startrange].present? && config[:fifthgear_endrange].present?
          options = {
            startRange: config[:fifthgear_startrange].to_i,
            endRange: config[:fifthgear_endrange].to_i
          }
        end

        FifthGear.item_inventory_bulk_lookup options
      end
    end
  end
end
