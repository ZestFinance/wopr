module Wopr
  class Bot
    class << self
      def create(name, params)
        params.merge!(name: name.to_s)
        self.new(params).tap do |bot|
          bots[name.to_sym] = bot
        end
      end

      def [](key)
        bots[key.to_sym]
      end

      def all
        bots.values
      end

      private

      def bots
        @bots ||= {}
      end
    end

    attr_accessor :phone_number, :name, :id

    def initialize(params)
      @attributes = {}
      params.each do |key, value|
        send(%Q{#{key.to_s}=}.to_sym, value)
      end
    end

    def on_a_call?
      wait_until do
        current_call
      end
    end

    def on_a_call_with?(another_bot)
      current_call.gather
      sleep 1
      another_bot.current_call.play '6661'
      wait_until do
        current_call.gathered_digits.last == '6661'
      end
    end

    def eventually(seconds=Wopr.default_wait_time)
      start_time = Time.now
      begin
        yield
      rescue => e
        raise e if (Time.now - start_time) >= seconds
        sleep 1
        retry
      end
    end

    def wait_until(seconds=Wopr.default_wait_time)
      eventually(seconds) do
        result = yield
        return result if result
        raise ConditionNotMetError
      end
    rescue ConditionNotMetError
      return false
    end

    def current_call
      Call.find_all_by_number(phone_number).select{|call| call.status != 'completed'}.last
    end

    def make_a_call_to(phone_number)
      Call.make(from: self.phone_number, to: phone_number)
    end

    private

    def method_missing(sym, *args)
      if sym.to_s =~ /(.+)=$/
        @attributes[$1.to_sym] = args.first
      else
        @attributes[sym]
      end
    end
  end
end
