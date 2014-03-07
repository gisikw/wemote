require 'socket'
require 'ipaddr'

module Wemote

  # This class encapsulates an individual Wemo Switch. It provides methods for
  # getting and setting the switch's state, as well as a {#toggle!} method for
  # convenience. Finally, it provides the {#poll} method, which accepts a block
  # to be executed any time the switch changes state.
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
      # Returns all Switches detected on the local network
      #
      # @param [Boolean] refresh Refresh and redetect Switches
      # @return [Array] all Switches on the network
      def all(refresh=false)
        @switches = nil if refresh
        @switches ||= Wemote::Collection::Switch.new(fetch_switches)
      end

      # Returns a Switch of a given name
      #
      # @param name [String] the friendly name of the Switch
      # @return [Wemote::Switch] a Switch object
      def find(name)
        all.detect{|s|s.name == name}
      end

      private

      def discover(socket = nil)
        @switches = nil
        @switches, socket = fetch_switches(true,socket)
        socket
      end

      def ssdp_socket
        socket = UDPSocket.new
        socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new(BIND_ADDR).hton)
        socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_TTL, 1)
        socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, 1)
        socket.bind(BIND_ADDR,PORT)
        socket
      end

      def listen(socket,switches)
        sleep 1
        Thread.start do
          loop do
            message, _ = socket.recvfrom(1024)
            if message.match(/LOCATION.*Belkin/m)
              switches << message.match(/LOCATION:\s+http:\/\/([^\/]+)/)[1].split(':')
            end
          end
        end
      end

      def fetch_switches(return_socket=false,socket=nil)
        socket ||= ssdp_socket
        switches = []

        3.times { socket.send(DISCOVERY, 0, MULTICAST_ADDR, PORT) }

        # The following is a bit silly, but is necessary for JRuby support,
        # which seems to have some issues with socket interruption. If you have
        # a working JRuby solution that doesn't require this kind of hackery,
        # by all means, submit a pull request!

        listen(socket,switches).tap{|l|sleep 1; l.kill}
        switches.uniq!.map!{|s|self.new(*s)}

        if return_socket
          [switches,socket]
        else
          socket.close
          switches
        end
      end
    end

    attr_accessor :name

    def initialize(host,port)
      @host, @port = host, port
      set_meta
    end

    # Turn the Switch on or off, based on its current state
    def toggle!;  on? ? off! : on!;   end

    # Turn the Switch off
    def off!;     set_state(0);       end

    # Turn the Switch on
    def on!;      set_state(1);       end

    # Return whether the Switch is off
    #
    # @return [Boolean]
    def off?;     get_state == :off;  end

    # Return whether the Switch is on
    #
    # @return [Boolean]
    def on?;      get_state == :on;   end

    # Monitors the state of the Switch via polling, and yields to the block
    # given with the updated state.
    #
    # @example Output when a Switch changes state
    #   light.poll do |state|
    #     if state == :on
    #       puts "The switch turned on"
    #     else
    #       puts "The switch turned off"
    #     end
    #   end
    #
    # @param rate [Float] The rate in seconds at which to poll the switch
    # @param async [Boolean] Whether or not to poll the switch in a separate thread
    #
    # @return [Thread] if the method call was asynchronous
    def poll(rate=0.25,async=true,&block)
      old_state = get_state
      poller = Thread.start do
        loop do
          state = get_state
          if state != old_state
            old_state = state
            yield state
          end
          sleep rate
        end
      end
      puts "Monitoring #{@name} for changes"
      async ? poller : poller.join
    end

    private

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

    def client
      @client ||= Wemote::Client.new
    end

    def set_meta
      response = client.get("http://#{@host}:#{@port}/setup.xml")
      @name = response.body.match(/<friendlyName>([^<]+)<\/friendlyName>/)[1]
    end

  end
end
