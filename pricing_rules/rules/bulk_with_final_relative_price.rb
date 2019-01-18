class BulkWithFinalRelativePrice < BasePricingRule
  # If you buy 3 or more units, the price of all units should drop to two thirds of the original price.
  class << self
    def apply_to(item)
      if item.quantity >= minimum
        item.product.unit_price * promotional_price_factor * item.quantity
      else
        item.product.unit_price * item.quantity
      end
    end

    def promotional_price_factor
      2.0 / 3.0
    end

    def minimum
      3
    end
  end
end
