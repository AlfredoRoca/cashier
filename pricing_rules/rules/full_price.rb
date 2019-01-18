class FullPrice < BasePricingRule
  def self.apply_to(item)
    item.product.unit_price * item.quantity
  end
end
