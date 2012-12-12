require 'wopr'

module Wopr
  module DSL
    def bot(name)
      Bot[name]
    end

    def using_wait_time(seconds, &block)
      Wopr.using_wait_time(seconds, &block)
    end
  end
end
