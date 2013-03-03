require "wopr/version"
require "yaml"
require "rainbow"

module Wopr
  class WoprError < StandardError; end
  class ConditionNotMetError < WoprError; end
  class TimeoutError < WoprError; end

  class << self
    CONFIG_PATH = File.join(File.dirname(__FILE__), '..', 'config', 'wopr.yml')

    attr_accessor :twilio_account_sid,
      :twilio_auth_token,
      :twilio_callback_host,
      :twilio_server_port,
      :default_wait_time

    def configure config_file = CONFIG_PATH
      check_config_existence  config_file

      config = YAML.load_file config_file

      check_twilio config
      create_bots  config

      @default_wait_time  = config['default_wait_time']  || 20
      @twilio_server_port = config['twilio_server_port'] || 4500
    end

    def boot
      TwilioService.new.update_callbacks(Wopr::Bot.all.map(&:phone_number))
      TwilioCallbackServer.boot
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

    def create_bots config
      config["bots"].each do |name, params|
        Wopr::Bot.create name, params
      end if config["bots"]
    end

    def check_twilio config
      if config["twilio_account_sid"].empty? || config["twilio_auth_token"].empty?
        puts "Dude, you need to configure twilio_account_sid and twilio_auth_token in config/wopr.yml".color(:red)
        exit 1
      else
        @twilio_account_sid = config["twilio_account_sid"]
        @twilio_auth_token  = config["twilio_auth_token"]
      end
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

    def find_available_port
      server = TCPServer.new('127.0.0.1', 0)
      server.addr[1]
    ensure
      server.close if server
    end
  end

  autoload :TwilioCallbackServer, 'wopr/twilio_callback_server'
  autoload :Call, 'wopr/call'
  autoload :TwilioService, 'wopr/twilio_service'
  autoload :Bot, 'wopr/bot'
  autoload :DSL, 'wopr/dsl'
end
