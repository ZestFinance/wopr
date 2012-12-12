require 'wopr'
require 'wopr/dsl'
require 'rspec/core'

RSpec.configure do |config|
  config.include Wopr::DSL, :wopr

  config.after do
    if self.class.include?(Wopr::DSL)
      Wopr::Call.destroy_all
    end
  end
end
