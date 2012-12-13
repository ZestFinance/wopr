require 'spec_helper'
require 'rack/test'

module Wopr
  describe TwilioCallbackServer do
    describe '.boot' do
      it 'starts the server' do
        TwilioCallbackServer.boot
      end
    end

    describe 'when running' do
      include ::Rack::Test::Methods
      let(:app) { TwilioCallbackServer }

      before do
        Wopr.twilio_callback_host = 'http://host.com'
      end

      describe 'GET /__identify__' do
        before do
          get '/__identify__'
        end

        it 'returns a 200 HTTP code' do
          last_response.status.should == 200
        end

        it 'returns the verification phrase' do
          last_response.body.should == TwilioCallbackServer::VERIFICATION_PHRASE
        end
      end

      describe 'POST /calls' do
        before do
          @count = Call.count

          post '/calls', CallSid: '1234'
        end

        it 'creates a new call' do
          Call.count.should == @count + 1
        end

        it 'says gibberish' do
          last_response.should have_tag('Say').with_attributes(loop: '0')
        end
      end

      describe 'POST /calls/:sid/play' do
        let(:digits) { '1234' }
        let(:sid) { 'fake' }

        before do
          post "/calls/#{sid}/play", digits: digits
        end

        it 'plays passed in digits' do
          last_response.should have_tag('Play').with_attributes(digits: digits)
        end

        it 'pauses for 10 seconds' do
          last_response.should have_tag('Pause').with_attributes(length: 10)
        end
      end

      describe 'POST /calls/:sid/gather' do
        let(:sid) { 'fake' }

        before do
          post "/calls/#{sid}/gather"
        end

        it 'waits 60 seconds to gather 4 digits' do
          last_response.should have_tag('Gather').with_attributes(timeout: 60, numDigits: 4)
        end

        it 'sends the gathered digits to the callback' do
          last_response.should have_tag('Gather').with_attributes(action: "#{Wopr.twilio_callback_host}/calls/#{sid}/gathered")
        end
      end

      describe 'POST /calls/:sid/gathered' do
        let(:sid) { 'fake' }
        let(:digits) { '1234' }

        let!(:call) { Call.create('CallSid' => sid) }

        before do
          post "/calls/#{sid}/gathered", Digits: digits
        end

        it 'adds the gathered digits to the call' do
          call.gathered_digits.last.should == digits
        end

        it 'says gibberish' do
          last_response.should have_tag('Say').with_attributes(loop: '0')
        end
      end
    end
  end
end
