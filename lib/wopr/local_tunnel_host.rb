require 'localtunnel'

module Wopr
  class LocalTunnelHost
    class << self
      def acquire(port)
        @host ||= LocalTunnelHost.new(port)
      end
    end

    def initialize(port)
      @port = port
      launch_tunnel
    end

    def to_s
      %Q(http://#{@host})
    end

    private

    def launch_tunnel
      tunnel = LocalTunnel::Tunnel.new(@port, nil)
      tunnel.register_tunnel

      tunnel_thread = Thread.new do
        tunnel.start_tunnel
      end

      tunnel_thread.join(5)

      @host = tunnel.host
    end
  end
end
