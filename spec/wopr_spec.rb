require 'spec_helper'

describe Wopr do
  describe ".boot" do
    before do
      @twilio_service = mock
      Wopr::TwilioService.stub(:new).and_return(@twilio_service)
      @twilio_service.stub :update_callbacks
      Wopr::TwilioCallbackServer.stub :boot
      Wopr.stub :configure
    end

    it "configures Wopr" do
      Wopr.should_receive :configure
      Wopr.boot
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

  describe ".configure" do
    context "given that configuration file exists" do
      before { File.stub(:exists?).and_return(true) }

      context "and there is twilio configuration" do
        before do
          @config = {
            "default_wait_time"    => 50,
            "twilio_server_port"   => 4501,
            "twilio_account_sid"   => "abc",
            "twilio_auth_token"    => "xyz",
            "twilio_callback_host" => "http://example.com"
          }
          YAML.stub(:load_file).and_return(@config)
        end

        it "sets twilio creds" do
          Wopr.configure
          Wopr.twilio_account_sid.should == "abc"
          Wopr.twilio_auth_token.should == "xyz"
        end

        it "sets twilio_callback_root" do
          Wopr.configure
          Wopr.twilio_callback_root.should == "http://example.com:4501"
        end

        it "configures the rest" do
          Wopr.configure
          Wopr.default_wait_time.should  == 50
          Wopr.twilio_server_port.should == 4501
        end
      end

      context "and there is no twilio configuration" do
        before do
          @config = { "twilio_account_sid"  => "" }
          YAML.stub(:load_file).and_return(@config)
        end

        it "complains about twilio and exits" do
          Wopr.should_receive(:puts).with(/you need to configure twilio/)
          expect { Wopr.configure }.to raise_error SystemExit
        end
      end

      context "and there is a bot" do
        before do
          @config = {
            "bots" => {
              "customer" => {
                "id" => 0,
                "phone_number" => 123
              }
            }
          }
          YAML.stub(:load_file).and_return(@config)
          Wopr.stub(:check_twilio)
        end

        it "creates a customer bot" do
          Wopr.configure

          customer = Wopr::Bot[:customer]
          customer.name.should == "customer"
          customer.phone_number.should == 123
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
end
