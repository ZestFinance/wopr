require 'spec_helper'

module Wopr
  describe Bot do
    describe "#four_random_digits" do
      before { @bot = Bot.new name: "bot1" }

      it "returns a string of four digits" do
        @bot.send(:four_random_digits).size.should == 4
      end

      it "returns a string of random digits" do
        one_set     = @bot.send :four_random_digits
        another_set = @bot.send :four_random_digits

        one_set.should_not == another_set
      end
    end
  end
end
