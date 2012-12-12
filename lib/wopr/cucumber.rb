require 'wopr'
require 'wopr/dsl'

World(Wopr::DSL)

After '@wopr' do
  Wopr::Call.hangup_and_destroy_all
end
