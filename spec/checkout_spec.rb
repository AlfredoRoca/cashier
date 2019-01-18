require_relative '../product_list.rb'
require_relative '../checkout.rb'

def get_list_of_products_without_pricing_rules
  ProductList.new('products_without_pricing_rules.txt').products
end

def get_list_of_products_with_pricing_rules
  ProductList.new('products_with_pricing_rules.txt').products
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
      products = get_list_of_products_without_pricing_rules
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
      products = get_list_of_products_without_pricing_rules
      co = described_class.new
      item = products[0]
      co.scan(item)
      co.scan(item)

      expect(co.items_list.size).to eq 1
    end

    it 'increments item quantity when adding an existing item', :aggregate_failures do
      products = get_list_of_products_without_pricing_rules
      co = described_class.new
      item = products[0]
      co.scan(item)
      co.scan(item)

      expect(co.items_list[0].quantity).to eq 2
    end
  end

  describe '#total' do
    context 'without any pricing rule' do
      it 'returns 0 if items list is empty' do
        co = described_class.new

        expect(co.total).to eq 0
      end

      it 'returns item unit price for just 1 item' do
        products = get_list_of_products_without_pricing_rules
        co = described_class.new
        basket = %w[GR1]
        expectation = 3.11 * basket.size
        basket.each { |item| co.scan(products.select { |product| product.code == item }.first) }

        expect(co.total).to eq expectation
      end

      it 'returns total price for a basket with only one type of item' do
        products = get_list_of_products_without_pricing_rules
        co = described_class.new
        basket = %w[SR1 SR1 SR1]
        expectation = 5 * basket.size
        basket.each { |item| co.scan(products.select { |product| product.code == item }.first) }

        expect(co.total).to eq expectation
      end

      it 'returns the sum of total prices when items are added randomly' do
        products = get_list_of_products_without_pricing_rules
        co = described_class.new
        basket = %w[SR1 GR1 SR1 GR1 CF1]
        expectation = 27.45
        basket.each { |item| co.scan(products.select { |product| product.code == item }.first) }

        expect(co.total).to eq expectation
      end
    end

    context 'with only items with BuyOneGetOneFree pricing rule' do
      context 'for a basket with an even number of items' do
        it 'returns the price with promotion' do
          products = get_list_of_products_with_pricing_rules
          co = described_class.new
          basket = %w[GR1 GR1 GR1 GR1 GR1 GR1]
          expectation = 9.33
          basket.each { |item| co.scan(products.select { |product| product.code == item }.first) }

          expect(co.total).to eq expectation
        end
      end

      context 'for a basket with an odd number of items' do
        it 'returns the price with promotion' do
          products = get_list_of_products_with_pricing_rules
          co = described_class.new
          basket = %w[GR1 GR1 GR1 GR1 GR1]
          expectation = 9.33
          basket.each { |item| co.scan(products.select { |product| product.code == item }.first) }

          expect(co.total).to eq expectation
        end
      end
    end

    context 'with only items with BulkWithFinalAbsolutePrice pricing rule' do
      context 'for a less quantity of items than minimum' do
        it 'returns the price without discount' do
          products = get_list_of_products_with_pricing_rules
          co = described_class.new
          basket = %w[SR1 SR1]
          expectation = 5 * basket.size
          basket.each { |item| co.scan(products.select { |product| product.code == item }.first) }

          expect(co.total).to eq expectation
        end
      end

      context 'for the minimum quantity ot items' do
        it 'returns the price with discount' do
          products = get_list_of_products_with_pricing_rules
          co = described_class.new
          basket = %w[SR1 SR1 SR1]
          expectation = 4.5 * basket.size
          basket.each { |item| co.scan(products.select { |product| product.code == item }.first) }

          expect(co.total).to eq expectation
        end
      end
    end

    context 'with only items with BulkWithFinalRelativePrice pricing rule' do
      context 'for a less quantity of items than minimum' do
        it 'returns the price without discount' do
          products = get_list_of_products_with_pricing_rules
          co = described_class.new
          basket = %w[CF1 CF1]
          expectation = 11.23 * basket.size
          basket.each { |item| co.scan(products.select { |product| product.code == item }.first) }

          expect(co.total).to eq expectation
        end
      end

      context 'for the minimum quantity ot items' do
        it 'returns the price with discount' do
          products = get_list_of_products_with_pricing_rules
          co = described_class.new
          basket = %w[CF1 CF1 CF1]
          expectation = 7.486666667 * basket.size
          basket.each { |item| co.scan(products.select { |product| product.code == item }.first) }

          expect(co.total).to be_within(0.1).of(expectation)
        end
      end
    end

# Basket: GR1,SR1,GR1,GR1,CF1
# Total price expected: ​ £22.45
# Basket: GR1,GR1
# Total price expected: ​ £3.11
# Basket: SR1,SR1,GR1,SR1
# Total price expected:​ £16.61
# Basket: GR1,CF1,SR1,CF1,CF1
# Total price expected:​ £30.57

    context 'with a mix of products and pricing rules' do
      it 'returns the happy price for the basket 1' do
        products = get_list_of_products_with_pricing_rules
        co = described_class.new
        basket = %w[GR1 SR1 GR1 GR1 CF1]
        expectation = 22.45
        basket.each { |item| co.scan(products.select { |product| product.code == item }.first) }

        expect(co.total).to be_within(0.1).of(expectation)
      end
    end
  end
end
