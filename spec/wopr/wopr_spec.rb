require 'spec_helper'

describe Wopr do
  describe 'passing a block to .configure' do
    it 'allows the block to set attributes on wopr' do
      Wopr.configure do |config|
        config.twilio_account_sid = 'foo'
        config.twilio_auth_token = 'bar'
      end
      Wopr.twilio_account_sid.should == 'foo'
      Wopr.twilio_auth_token = 'bar'
    end
  end
end
