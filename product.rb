class Product
  attr_accessor :code, :name, :unit_price, :pricing_rule

  def initialize(code, name, unit_price, pricing_rule)
    @code = code
    @name = name
    @unit_price = unit_price
    @pricing_rule = pricing_rule
  end
end
