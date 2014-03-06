require 'socket'
require 'ipaddr'

module Wemote
  class Switch
    MULTICAST_ADDR = '239.255.255.250'
    BIND_ADDR = '0.0.0.0'
    PORT = 1900
    DISCOVERY= <<-EOF
M-SEARCH * HTTP/1.1\r
HOST: 239.255.255.250:1900\r
MAN: "ssdp:discover"\r
MX: 10\r
ST: urn:Belkin:device:lightswitch:1\r
\r
EOF

    GET_HEADERS = {
      "SOAPACTION"   => '"urn:Belkin:service:basicevent:1#GetBinaryState"',
      "Content-type" => 'text/xml; charset="utf-8"'
    }

    SET_HEADERS = {
      "SOAPACTION"   => '"urn:Belkin:service:basicevent:1#SetBinaryState"',
      "Content-type" => 'text/xml; charset="utf-8"'
    }

    class << self
      def all(refresh=false)
        @switches = nil if refresh
        @switches ||= fetch_switches
      end

      def find(name)
        all.detect{|s|s.name == name}
      end

      private

      def fetch_switches
        socket = UDPSocket.new
        membership = IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new(BIND_ADDR).hton

        socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, membership)
        socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_TTL, 1)
        socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, 1)
        socket.bind(BIND_ADDR,PORT)

        switches = []

        3.times { socket.send(DISCOVERY, 0, MULTICAST_ADDR, PORT) }

        # The following is a bit silly, but is necessary for JRuby support,
        # which seems to have some issues with socket interruption.
        # If you have a working JRuby solution that doesn't require this
        # kind of hackery, by all means, submit a pull request!

        sleep 1

        parser = Thread.start do
          loop do
            message, _ = socket.recvfrom(1024)
            if message.match(/LOCATION.*Belkin/m)
              switches << message.match(/LOCATION:\s+http:\/\/([^\/]+)/)[1].split(':')
            end
          end
        end

        sleep 1
        parser.kill

        socket.close

        return switches.uniq.map{|s|self.new(*s)}

      end
    end

    attr_accessor :name

    def initialize(host,port)
      @host, @port = host, port
      set_meta
    end

    def toggle!;  on? ? off! : on!;   end
    def off!;     set_state(0);       end
    def off?;     get_state == :off;  end
    def on!;      set_state(1);       end
    def on?;      get_state == :on;   end

    def get_state
      response = begin
        client.post("http://#{@host}:#{@port}/upnp/control/basicevent1",Wemote::XML.get_binary_state,GET_HEADERS)
      rescue Exception
        client.post("http://#{@host}:#{@port}/upnp/control/basicevent1",Wemote::XML.get_binary_state,GET_HEADERS)
      end
      response.body.match(/<BinaryState>(\d)<\/BinaryState>/)[1] == '1' ? :on : :off
    end

    def set_state(state)
      begin
        client.post("http://#{@host}:#{@port}/upnp/control/basicevent1",Wemote::XML.set_binary_state(state),SET_HEADERS)
      rescue Exception
        client.post("http://#{@host}:#{@port}/upnp/control/basicevent1",Wemote::XML.set_binary_state(state),SET_HEADERS)
      end
    end

    private

    def client
      @client ||= Wemote::Client.new
    end

    def set_meta
      response = client.get("http://#{@host}:#{@port}/setup.xml")
      @name = response.body.match(/<friendlyName>([^<]+)<\/friendlyName>/)[1]
    end

  end
end
