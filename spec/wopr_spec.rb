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

  describe ".boot" do
    before do
      Wopr.twilio_account_sid = 'fake_sid'
      Wopr.twilio_auth_token  = 'auth_token'
      @twilio_service = Wopr::TwilioService.new
      Wopr::TwilioService.stub(:new).and_return(@twilio_service)
    end

    it "updates twilio callbacks" do
      @twilio_service.should_receive :update_callbacks
      Wopr.boot
    end

    it "boots the TwilioCallbackServer" do
      Wopr::TwilioCallbackServer.should_receive :boot
      Wopr.boot
    end
  end
end
