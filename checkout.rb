require './item.rb'

class Checkout
  attr_reader :items_list

  def initialize
    @items_list = []
  end

  def scan(item)
    return unless item

    found = @items_list.select { |item_in_list| item_in_list.product.code == item.code }.first
    @items_list.delete(found)

    return @items_list.push(Item.new(item, found.quantity + 1)) if found

    @items_list.push(Item.new(item, 1))
  end

  def total
    return 0 if @items_list.empty?

    return @items_list.map { |item| item.apply_pricing_rule }.reduce(:+)
  end
end
