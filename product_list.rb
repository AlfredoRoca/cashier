require './product.rb'

class ProductList
  attr_reader :products

  def initialize(data_file)
    @products = read_products_from_file(data_file)
  end

  def read_products_from_file(data_file)
    return [] unless File.exist?(data_file)

    products = Array.new
    file_lines = IO.readlines(data_file)
    file_lines.each do |line|
      code, name, unit_price, pricing_rule = line.split(',')
      begin
        products.push Product.new(code, name, unit_price, pricing_rule)
      rescue StandardError => error
        puts error.message, "Error in line: #{line}"
      end
    end
    products
  end
end
