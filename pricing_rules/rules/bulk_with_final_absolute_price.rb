class BulkWithFinalAbsolutePrice < BasePricingRule
  # If you buy 3 or more units, the price should drop to a fixed price
  def self.apply_to(item)
    if item.product.minimum.positive? && item.quantity >= item.product.minimum
      item.product.promotion * item.quantity
    else
      item.product.unit_price * item.quantity
    end
  end
end
