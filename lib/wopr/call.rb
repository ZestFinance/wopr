module Wopr
  class Call
    class << self
      def make(options)
        TwilioService.new.make(options)
      end

      def create(params={})
        self.new(params).tap do |call|
          calls << call
        end
      end

      def destroy_all
        @calls = []
      end

      def hangup_all
        calls.each do |call|
          call.hangup
        end
      end

      def hangup_and_destroy_all
        hangup_all
        destroy_all
      end

      def count
        calls.count
      end

      def all
        calls
      end

      def find_by_number(number)
        calls.find do |call|
          call.from =~ /#{number}$/ ||
            call.to =~/#{number}$/
        end
      end

      def find_all_by_number(number)
        calls.select do |call|
          call.from =~ /#{number}$/ ||
            call.to =~/#{number}$/
        end
      end

      def find_by_sid(sid)
        calls.find do |call|
          call.sid == sid
        end
      end

      private

      def calls
        @calls ||= []
      end
    end

    def initialize(params={})
      @params = params
    end

    def update(params={})
      @params.merge! params
    end

    def hangup
      TwilioService.new.hangup sid
    end

    def number
      @params['Called']
    end

    def from
      @params['From']
    end

    def to
      @params['To']
    end

    def play(digits)
      TwilioService.new.play sid, digits
    end

    def gather
      TwilioService.new.gather sid
    end

    def gathered(digits)
      gathered_digits << digits
    end

    def gathered_digits
      @gathered_digits ||= []
    end

    def sid
      @params['CallSid']
    end

    def status
      @params['CallStatus']
    end
  end
end
