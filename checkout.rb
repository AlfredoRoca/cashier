require './item.rb'

class Checkout
  attr_reader :items_list

  def initialize
    @items_list = []
  end

  def scan(item)
    return unless item

    return if update_quantity_of_existing(item)
    add_new_item(item)
  end

  def total
    return 0 if @items_list.empty?

    return @items_list.map { |item| item.apply_pricing_rule }.reduce(:+)
  end

  private

  def update_quantity_of_existing(item)
    found = @items_list.select { |item_in_list| item_in_list.product.code == item.code }.first
    return false unless found

    @items_list.delete(found)
    @items_list.push(Item.new(item, found.quantity + 1))
  end

  def add_new_item(item)
    @items_list.push(Item.new(item, 1))
  end
end
