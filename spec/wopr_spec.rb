require 'spec_helper'

describe Wopr do
  describe ".configure" do
    context "given that configuration file exists" do
      before { File.stub(:exists?).and_return(true) }

      context "and there are twilio credentials" do
        before do
          @config = {
            "default_wait_time"   => 50,
            "twilio_server_port"  => 4501,
            "twilio_account_sid"  => "abc",
            "twilio_auth_token"   => "xyz"
          }
          YAML.stub(:load_file).and_return(@config)
        end

        it "sets twilio creds" do
          Wopr.configure
          Wopr.twilio_account_sid.should == "abc"
          Wopr.twilio_auth_token.should == "xyz"
        end

        it "configures the rest" do
          Wopr.configure
          Wopr.default_wait_time.should  == 50
          Wopr.twilio_server_port.should == 4501
        end
      end

      context "and there is no twilio credentials" do
        before do
          @config = { "twilio_account_sid"  => "" }
          YAML.stub(:load_file).and_return(@config)
        end

        it "complains about twilio and exits" do
          Wopr.should_receive(:puts).with(/you need to configure twilio/)
          expect { Wopr.configure }.to raise_error SystemExit
        end
      end
    end

    context "given there is no configuration file" do
      before { File.stub(:exists?).and_return(false) }

      it "fails and complains" do
        Wopr.should_receive(:complain)
        expect { Wopr.configure }.to raise_error
      end
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
