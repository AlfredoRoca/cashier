require_relative './base_pricing_rule.rb'
Dir[File.join(__dir__, 'rules', '*.rb')].each { |file| require file }
