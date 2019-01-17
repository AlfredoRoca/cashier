require_relative '../product_list.rb'
require_relative '../checkout.rb'

def get_list_of_products_with_prices
  ProductList.new.products
end

RSpec.describe Checkout do

  describe 'initialization' do
    it 'stores provided pricing_rules as an Array' do
      pricing_rules = ['dummy content']

      expect(described_class.new(pricing_rules).pricing_rules).to eq pricing_rules
    end

    it 'initializes the items list as an empty Array' do
      expect(described_class.new.items_list).to eq []
    end
  end

  describe '#scan' do
    it 'registers item in the items list' do
      products = get_list_of_products_with_prices
      co = described_class.new
      item = products[0]
      co.scan(item)

      expect(co.items_list.size).to eq 1
    end

    it 'does not change items list if item is nil' do
      co = described_class.new
      co.scan(nil)

      expect(co.items_list.size).to eq 0
    end

    it 'does not stores a new item when adding an existing one' do
      products = get_list_of_products_with_prices
      co = described_class.new
      item = products[0]
      co.scan(item)
      co.scan(item)

      expect(co.items_list.size).to eq 1
    end

    it 'increments item quantity when adding an existing item', :aggregate_failures do
      products = get_list_of_products_with_prices
      co = described_class.new
      item = products[0]
      co.scan(item)
      co.scan(item)

      expect(co.items_list[0][:quantity]).to eq 2
    end
  end

  describe '#total' do
    context 'without any pricing rule' do
      it 'returns 0 if items list is empty' do
        co = described_class.new

        expect(co.total).to eq 0
      end

      it 'returns item unit price for just 1 item' do
        products = get_list_of_products_with_prices
        co = described_class.new
        co.scan(products[0])

        expect(co.total).to eq products[0].unit_price
      end

      it 'returns item unit price multiplied by quantity for 1-item list several times' do
        products = get_list_of_products_with_prices
        co = described_class.new
        2.times { co.scan(products[0]) }

        expect(co.total).to eq products[0].unit_price * 2
      end

      it 'returns the sum of total prices when items are added randomly' do
        products = get_list_of_products_with_prices
        co = described_class.new
        co.scan(products[0])
        co.scan(products[1])
        co.scan(products[0])
        co.scan(products[1])
        co.scan(nil)
        co.scan(products[1])

        expect(co.total).to eq products[0].unit_price * 2 + products[1].unit_price * 3
      end
    end
  end
end
