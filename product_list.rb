require './product.rb'

class ProductList
  attr_reader :products

  def initialize
    @products = read_products_from_file
  end

  def read_products_from_file
    products_file = File.join(__dir__, 'products.txt')
    return [] unless File.exist?(products_file)

    products = Array.new
    file_lines = IO.readlines(products_file)
    file_lines.each do |line|
      code, name, unit_price = line.split(',')
      begin
        products.push Product.new(code, name.strip, unit_price.to_f, nil)
      rescue StandardError => error
        puts error.message, "Error in line: #{line}"
      end
    end
    products
  end
end
