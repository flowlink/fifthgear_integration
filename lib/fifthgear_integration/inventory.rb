module FifthGearIntegration
  class Inventory < Base
    attr_reader :inventory
    attr_accessor :collection

    def initialize(config, payload = {})
      super config, payload
      @inventory = payload[:inventory] || {}
      @collection = []
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

        @collection = FifthGear.item_inventory_bulk_lookup options
      end
    end

    def next_start
      if collection.count > 0
        config[:fifthgear_endrange].to_i + 1
      else
        1
      end
    end

    def next_end
      diff = config[:fifthgear_endrange].to_i - config[:fifthgear_startrange].to_i
      if next_start == 1
        diff + 1
      else
        next_start + diff
      end
    end
  end
end
