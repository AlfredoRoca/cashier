class Checkout
  attr_reader :items_list, :pricing_rules

  def initialize(pricing_rules = [])
    @pricing_rules = pricing_rules
    @items_list = []
  end

  def scan(item)
    return unless item

    found = @items_list.bsearch { |item_in_list| item_in_list[:item].code == item.code }
    @items_list.delete(found)
    return @items_list.push({ item: item, quantity: found[:quantity] + 1 }) if found

    @items_list.push({ item: item, quantity: 1 })
  end

  def total
    return 0 if @items_list.empty?

    return @items_list.map { |item| item[:item].unit_price * item[:quantity] }.reduce(:+)
  end
end
