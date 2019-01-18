class BulkWithFinalAbsolutePrice < BasePricingRule
  # If you buy 3 or more units, the price should drop to a fixed price
  class << self
    def apply_to(item)
      if item.quantity >= minimum
        promotional_price * item.quantity
      else
        item.product.unit_price * item.quantity
      end
    end

    def promotional_price
      4.5
    end

    def minimum
      3
    end
  end
end
