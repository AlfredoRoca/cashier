require_relative '../product_list.rb'
require_relative '../checkout.rb'

def get_list_of_products_without_pricing_rules
  ProductList.new('products_without_pricing_rules.txt').products
end

def get_list_of_products_with_pricing_rules
  ProductList.new('products_with_pricing_rules.txt').products
end

RSpec.shared_examples 'a good cashier' do
  it 'calculating the happy price applying promotions' do
    co = described_class.new
    basket.each { |item| co.scan(products.select { |product| product.code == item }.first) }

    if defined? rounded && rounded then
      expect(co.total).to be_within(0.01).of(expectation)
    else
      expect(co.total).to eq expectation
    end
  end
end

RSpec.describe Checkout do
  describe 'initialization' do
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
      context 'and an empty basket' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_without_pricing_rules }
          let(:basket) { [] }
          let(:expectation) { 0 }
        end
      end

      context 'for just 1 item' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_without_pricing_rules }
          let(:basket) { %w[GR1] }
          let(:expectation) { 3.11 * basket.size }
        end
      end

      context 'for only one type of items' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_without_pricing_rules }
          let(:basket) { %w[SR1 SR1 SR1] }
          let(:expectation) { 5 * basket.size }
        end
      end

      context 'for items added randomly' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_without_pricing_rules }
          let(:basket) { %w[SR1 GR1 SR1 GR1 CF1] }
          let(:expectation) { 27.45 }
        end
      end
    end

    context 'with only items with BuyOneGetOneFree pricing rule' do
      context 'for a basket with just 1 item' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_with_pricing_rules }
          let(:basket) { %w[GR1] }
          let(:expectation) { 3.11 }
        end
      end

      context 'for a basket with an even number of items' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_with_pricing_rules }
          let(:basket) { %w[GR1 GR1 GR1 GR1 GR1 GR1] }
          let(:expectation) { 9.33 }
        end
      end

      context 'for a basket with an odd number of items' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_with_pricing_rules }
          let(:basket) { %w[GR1 GR1 GR1 GR1 GR1] }
          let(:expectation) { 9.33 }
        end
      end
    end

    context 'with only items with BulkWithFinalAbsolutePrice pricing rule' do
      context 'for a less quantity of items than minimum' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_with_pricing_rules }
          let(:basket) { %w[SR1 SR1] }
          let(:expectation) { 5 * basket.size }
        end
      end

      context 'for the minimum quantity ot items' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_with_pricing_rules }
          let(:basket) { %w[SR1 SR1 SR1] }
          let(:expectation) { 4.5 * basket.size }
        end
      end
    end

    context 'with only items with BulkWithFinalRelativePrice pricing rule' do
      context 'for a less quantity of items than minimum' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_with_pricing_rules }
          let(:basket) { %w[CF1 CF1] }
          let(:expectation) { 11.23 * basket.size }
        end
      end

      context 'for the minimum quantity ot items' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_with_pricing_rules }
          let(:basket) { %w[CF1 CF1 CF1] }
          let(:expectation) { 7.486666667 * basket.size }
          let(:rounded) { true }
        end
      end
    end

    context 'with a mix of products and pricing rules' do
      context 'like basket 1' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_with_pricing_rules }
          let(:basket) { %w[GR1 SR1 GR1 GR1 CF1] }
          let(:expectation) { 22.45 }
          let(:rounded) { true }
        end
      end

      context 'like basket 2' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_with_pricing_rules }
          let(:basket) { %w[GR1 GR1] }
          let(:expectation) { 3.11 }
          let(:rounded) { true }
        end
      end

      context 'like basket 3' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_with_pricing_rules }
          let(:basket) { %w[SR1 SR1 GR1 SR1] }
          let(:expectation) { 16.61 }
          let(:rounded) { true }
        end
      end

      context 'like basket 4' do
        it_behaves_like 'a good cashier' do
          let(:products) { get_list_of_products_with_pricing_rules }
          let(:basket) { %w[GR1 CF1 SR1 CF1 CF1] }
          let(:expectation) { 30.57 }
          let(:rounded) { true }
        end
      end
    end
  end
end
