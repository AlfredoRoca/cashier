require './pricing_rules/load_pricing_rules.rb'

class Product
  attr_accessor :code, :name, :unit_price, :pricing_rule

  def initialize(code, name, unit_price, pricing_rule)
    @code = code
    @name = name.strip
    @unit_price = unit_price.to_f
    @pricing_rule = pricing_rule.nil? ? FullPrice : Object.const_get(pricing_rule.strip)
  end
end
