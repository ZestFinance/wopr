require 'spec_helper'

module Wopr
  describe Call do
    describe ".create" do
      let!(:call) { Call.create }

      it "initializes a call" do
        call.should be
      end

      it "add the call to the list of all calls" do
        Call.all.last.should == call
      end
    end

    describe '.count' do
      before do
        2.times do
          Call.create
        end
      end

      it 'return the number of existing calls' do
        Call.count.should == 2
      end
    end

    describe '.destroy_all' do
      before do
        2.times do
          Call.create
        end

        Call.destroy_all
      end

      it 'empty the call list' do
        Call.all.should be_empty
      end
    end

    describe '.hangup_all' do
      before do
        @hangup_count = 0

        2.times do
          Call.create
        end

        Call.any_instance.stub(:hangup) do
          @hangup_count += 1
        end

        Call.hangup_all
      end

      it 'hangs up all the existing calls' do
        @hangup_count.should == 2
      end
    end

    describe '.hangup_and_destroy_all' do
      it 'calls hangup_all then call destroy_all' do
        Call.should_receive(:hangup_all).ordered
        Call.should_receive(:destroy_all).ordered.at_least 1

        Call.hangup_and_destroy_all
      end
    end

    describe '.all' do
      let(:calls) { [] }
      before do
        2.times do
          calls << Call.create
        end
      end

      it 'returns all the calls' do
        Call.all.should =~ calls
      end
    end

    describe '.find_by_number' do
      let(:number) { '1234567890' }
      let!(:call1) { Call.create('From' => number) }
      let!(:call2) { Call.create('From'=> number) }
      let!(:found_call) { Call.find_by_number number }

      it "finds the first call on the number" do
        found_call.should == call1
      end
    end

    describe '.find_by_sid' do
      let(:sid) { 'fake' }
      let!(:call1) { Call.create('CallSid' => sid) }
      let!(:call2) { Call.create('CallSid'=> sid) }
      let!(:found_call) { Call.find_by_sid sid }

      it "finds the first call with the sid" do
        found_call.should == call1
      end
    end

    describe '#hangup' do
      let(:sid) { 'fake' }
      let(:call) { Call.new('CallSid' => sid) }
      let(:twilio_service) {mock(TwilioService)}

      before { TwilioService.stub(:new).and_return(twilio_service) }

      it 'hangs up the call on Twilio' do
        twilio_service.should_receive(:hangup).with(sid)
        call.hangup
      end

      it 'destroys the call' do
        twilio_service.stub :hangup
        call.should_receive :destroy
        call.hangup
      end
    end

    describe '#number' do
      let(:number) { '1234567890' }
      let(:call) { Call.new('Called' => number) }

      it "returns the Called parameter the call was created with" do
        call.number.should == number
      end
    end

    describe '#play' do
      let(:sid) { 'fake' }
      let(:digits) { '1234' }
      let(:call) { Call.new('CallSid' => sid) }
      let(:twilio_service) {mock(TwilioService)}

      it 'plays the digits on the call on Twilio' do
        TwilioService.stub(:new).and_return(twilio_service)
        twilio_service.should_receive(:play).with(sid, digits)
        call.play digits
      end
    end

    describe '#gather' do
      let(:sid) { 'fake' }
      let(:call) { Call.new('CallSid' => sid) }
      let(:twilio_service) {mock(TwilioService)}

      it 'gathers digits on the call on Twilio' do
        TwilioService.stub(:new).and_return(twilio_service)
        twilio_service.should_receive(:gather).with(sid)
        call.gather
      end
    end

    describe '#gathered' do
      let(:call) { Call.new }
      let(:digits) { '1234' }

      before do
        call.gathered digits
      end

      it 'add the digits to the list of gathered digits' do
        call.gathered_digits.last.should == digits
      end
    end

    describe '#gathered_digits' do
      let(:call) { Call.new }

      before do
        call.gathered('1234')
        call.gathered('5678')
        call.gathered('0000')
      end

      it 'returns the list of gathered digits' do
        call.gathered_digits.should =~ ['1234', '5678', '0000']
      end
    end

    describe '#sid' do
      let(:sid) { 'fake' }
      let(:call) { Call.new('CallSid' => sid) }

      it "returns the CallSid parameter the call was created with" do
        call.sid.should == sid
      end
    end

    describe '#destroy' do
      let(:sid) { 'fake' }
      let(:call) { Call.new('CallSid' => sid) }

      it 'deletes the call' do
        call.destroy
        Call.find_by_sid(sid).should be_nil
      end
    end
  end
end
