require "wopr/version"

module Wopr
  class WoprError < StandardError; end
  class ConditionNotMetError < WoprError; end
  class TimeoutError < WoprError; end

  class << self
    attr_accessor :twilio_account_sid, :twilio_auth_token, :port, :twilio_callback_host, :twilio_server_port,
      :default_wait_time

    def configure
      yield self
    end

    def boot
      TwilioService.new.update_callbacks(Wopr::Bot.all.map(&:phone_number))
      TwilioCallbackServer.boot
    end

    def twilio_callback_host
      @twilio_callback_host ||= LocalTunnelHost.acquire(twilio_server_port)
    end

    def twilio_server_port
      @twilio_server_port ||= find_available_port
    end

    def using_wait_time(seconds)
      previous_wait_time = Wopr.default_wait_time
      Wopr.default_wait_time = seconds
      yield
    ensure
      Wopr.default_wait_time = previous_wait_time
    end

    private

    def find_available_port
      server = TCPServer.new('127.0.0.1', 0)
      server.addr[1]
    ensure
      server.close if server
    end
  end

  autoload :TwilioCallbackServer, 'wopr/twilio_callback_server'
  autoload :Call, 'wopr/call'
  autoload :LocalTunnelHost, 'wopr/local_tunnel_host'
  autoload :TwilioService, 'wopr/twilio_service'
  autoload :Bot, 'wopr/bot'
  autoload :DSL, 'wopr/dsl'
end

Wopr.configure do |configure|
  configure.default_wait_time = 20
end
