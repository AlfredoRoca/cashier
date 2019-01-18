class BulkWithFinalRelativePrice < BasePricingRule
  # If you buy 3 or more units, the price of all units should drop to two thirds of the original price.
  def self.apply_to(item)
    if item.product.minimum.positive? && item.quantity >= item.product.minimum
      item.product.unit_price * item.product.promotion * item.quantity
    else
      item.product.unit_price * item.quantity
    end
  end
end
