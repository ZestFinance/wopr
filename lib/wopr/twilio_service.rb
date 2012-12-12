require 'twilio-ruby'

module Wopr
  class TwilioService
    def initialize
      @twilio_client = Twilio::REST::Client.new Wopr.twilio_account_sid, Wopr.twilio_auth_token
    end

    def make(options)
      calls.create(options.merge(url: "#{Wopr.twilio_callback_host}/calls"))
    end

    def hangup(sid)
      call(sid).hangup
    end

    def play(sid, digits)
      call(sid).redirect_to "#{Wopr.twilio_callback_host}/calls/#{sid}/play?digits=#{digits}"
    end

    def gather(sid)
      call(sid).redirect_to "#{Wopr.twilio_callback_host}/calls/#{sid}/gather"
    end

    def update_callbacks(numbers)
      numbers.each do |number|
        incoming_numbers = @twilio_client.account.incoming_phone_numbers.list(phone_number: number)
        unless incoming_numbers.empty?
          incoming_number = incoming_numbers.first
          incoming_number.update(voice_url: "#{Wopr.twilio_callback_host}/calls",
                                 status_callback_url: "#{Wopr.twilio_callback_host}/calls")
        end
      end
    end

   private

    def calls
      @twilio_client.account.calls
    end

    def call(sid)
      calls.get(sid)
    end
  end
end
