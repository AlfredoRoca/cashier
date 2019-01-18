class BasePricingRule
  def self.apply_to(item)
    raise "method 'self.apply_to(item)' not implemented in #{self.to_s}"
  end
end
