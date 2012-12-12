require 'bundler/setup'
Bundler.require :default, :development, :test

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'wopr'

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

RSpec.configure do |configure|
  configure.mock_with :rspec
  configure.include XMLMatchers
  configure.after(:each) do
    Wopr::Call.destroy_all
  end
end
