class Item
  attr_accessor :product, :quantity

  def initialize(product, quantity)
    @product = product
    @quantity = quantity
  end

  def apply_pricing_rule
    @product.pricing_rule.apply_to(self)
  end
end
