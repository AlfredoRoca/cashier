class BuyOneGetOneFree < BasePricingRule
  def self.apply_to(item)
    item.product.unit_price * (item.quantity / 2 + item.quantity % 2)
  end
end
