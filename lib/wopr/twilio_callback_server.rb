require 'sinatra/base'
require 'net/http'
require 'builder'

module Wopr
  class TwilioCallbackServer < Sinatra::Base
    VERIFICATION_PHRASE = 'SHALL WE PLAY A GAME?'

    set :views, File.join(File.dirname(__FILE__), 'templates')

    get '/__identify__' do
      [200, {}, VERIFICATION_PHRASE]
    end

    post '/calls' do
      if(call = Call.find_by_sid(params[:CallSid]))
        call.update params
      else
        Call.create(params)
      end

      builder :default
    end

    post '/calls/status' do
      if(call = Call.find_by_sid(params[:CallSid]))
        call.update params
      end
    end

    post '/calls/:sid/play' do
      builder :play, locals: { sid: params[:sid], digits: params[:digits] }
    end

    post '/calls/:sid/gather' do
      builder :gather, locals: { sid: params[:sid] }
    end

    post '/calls/:sid/gathered' do
      if(call = Call.find_by_sid(params[:sid]))
        call.gathered params[:Digits]
      end

      builder :default
    end

    class << self
      attr_reader :callback_host, :port

      def boot(port=Wopr.twilio_server_port)
        @port = port

        unless responsive?
          @server_thread = Thread.new do
            run_server(@port)
          end
        end

        Timeout.timeout(60) do
          @server_thread.join(0.1) until responsive?
        end
      end

      def responsive?
        return false if @server_thread && @server_thread.join(0)

        res = Net::HTTP.start('127.0.0.1', @port) { |http| http.get('/__identify__') }

        if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
          return res.body == VERIFICATION_PHRASE
        end
      rescue Errno::ECONNREFUSED, Errno::EBADF
        return false
      end

      private

      def run_server(port)
        require 'rack/handler/thin'
        Thin::Logging.silent = true
        Rack::Handler::Thin.run(self,
                                Port: port)
      rescue LoadError
        require 'rack/handler/webrick'
        Rack::Handler::WEBrick.run(self,
                                   Port: port,
                                   AccessLog: [],
                                   Logger: WEBrick::Log::new(nil, 0))
      end
    end
  end
end
