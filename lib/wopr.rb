require "wopr/version"
require "yaml"
require "rainbow"

module Wopr
  class WoprError < StandardError; end
  class ConditionNotMetError < WoprError; end
  class TimeoutError < WoprError; end

  class << self
    attr_accessor :twilio_account_sid,
      :twilio_auth_token,
      :twilio_callback_host,
      :twilio_server_port,
      :twilio_callback_root,
      :default_wait_time

    DEFAULT_CONFIG = 'config/wopr.yml'

    def boot config_file = DEFAULT_CONFIG
      configure config_file
      TwilioService.new.update_callbacks(Wopr::Bot.all.map(&:phone_number))
      TwilioCallbackServer.boot
    end

    def configure config_file = DEFAULT_CONFIG
      check_config_existence  config_file

      config = YAML.load_file config_file

      check_twilio      config
      create_bots       config
      override_defaults config
    end

    def using_wait_time(seconds)
      previous_wait_time = Wopr.default_wait_time
      Wopr.default_wait_time = seconds
      yield
    ensure
      Wopr.default_wait_time = previous_wait_time
    end

    private

    def create_bots config
      config["bots"].each do |name, params|
        Wopr::Bot.create name, params
      end if config["bots"]
    end

    def check_twilio config
      if config["twilio_account_sid"].empty? ||
         config["twilio_auth_token"].empty?  ||
         config["twilio_callback_host"].empty?
        puts "Dude, you need to configure twilio in config/wopr.yml".color(:red)
        exit 1
      else
        @twilio_account_sid   = config["twilio_account_sid"]
        @twilio_auth_token    = config["twilio_auth_token"]
        @twilio_callback_host = config['twilio_callback_host']
        @twilio_server_port   = config['twilio_server_port'] || 4500
        @twilio_callback_root = "#{@twilio_callback_host}:#{@twilio_server_port}"
      end
    end

    def override_defaults config
      @default_wait_time = config['default_wait_time'] || 20
    end

    def check_config_existence config_file
      unless File.exists? File.expand_path(config_file)
        complain
        exit 1
      end
    end

    def complain
      puts "---"
      puts "Gash! wopr is not configured".color(:red)
      puts "Open config/wopr.yml and follow the instructions"
    end
  end

  autoload :TwilioCallbackServer, 'wopr/twilio_callback_server'
  autoload :Call, 'wopr/call'
  autoload :TwilioService, 'wopr/twilio_service'
  autoload :Bot, 'wopr/bot'
  autoload :DSL, 'wopr/dsl'
end
