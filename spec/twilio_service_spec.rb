require 'spec_helper'

module Wopr
  describe TwilioService do
    let(:twilio_client) { mock(Twilio::REST::Client) }
    let(:call) { mock() }
    let(:calls) { mock() }
    let(:sid) { 'fake' }

    before do
      Wopr.twilio_callback_host = 'http://host'
      Twilio::REST::Client.should_receive(:new).with(
        Wopr.twilio_account_sid, Wopr.twilio_auth_token).
        and_return(twilio_client)
      twilio_client.stub_chain(:account, :calls).and_return(calls)
      calls.stub(:get).with(sid).and_return(call)
    end

    after do
      Wopr.twilio_callback_host = nil
    end

    describe '#initalize' do
      it "create a twilio client" do
        TwilioService.new
      end
    end

    describe '#hangup' do
      it "hangs up the call on twilio" do
        call.should_receive(:hangup)
        TwilioService.new.hangup sid
      end
    end

    describe '#play' do
      let(:digits) { '1234' }

      it "redirects the twilio call to the play callback" do
        call.should_receive(:redirect_to).
          with("#{Wopr.twilio_callback_host}/calls/#{sid}/play?digits=#{digits}")
        TwilioService.new.play sid, digits
      end
    end

    describe '#gather' do
      it "redirects the twilio call to the gather callback" do
        call.should_receive(:redirect_to).
          with("#{Wopr.twilio_callback_host}/calls/#{sid}/gather")
        TwilioService.new.gather sid
      end
    end
  end
end
