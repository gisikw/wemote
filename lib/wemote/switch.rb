require 'socket'
require 'ipaddr'
require 'timeout'

module Wemote

  # This class encapsulates an individual Wemo Switch. It provides methods for
  # getting and setting the switch's state, as well as a {#toggle!} method for
  # convenience. Finally, it provides the {#poll} method, which accepts a block
  # to be executed any time the switch changes state.
  class Switch

    GET_HEADERS = {
      "SOAPACTION"   => '"urn:Belkin:service:basicevent:1#GetBinaryState"',
      "Content-type" => 'text/xml; charset="utf-8"'
    }

    SET_HEADERS = {
      "SOAPACTION"   => '"urn:Belkin:service:basicevent:1#SetBinaryState"',
      "Content-type" => 'text/xml; charset="utf-8"'
    }

    class << self

      def device_type
        'urn:Belkin:device:controllee:1'
      end

      # Returns all Switches detected on the local network
      #
      # @param [Boolean] refresh Refresh and redetect Switches
      # @return [Array] all Switches on the network
      def all(refresh=false)
        @switches = nil if refresh
        @switches ||= Wemote::Collection::Switch.new(discover)
      end

      # Returns a Switch of a given name
      #
      # @param name [String] the friendly name of the Switch
      # @return [Wemote::Switch] a Switch object
      def find(name)
        all.detect{|s|s.name == name}
      end

      protected

      def discover
        finder = SSDP::Consumer.new timeout: 3, first_only: false
        finder.search(service: self.device_type).map do |device|
          self.new(device[:address], device[:params]['LOCATION'].match(/:([0-9]{1,5})\//)[1])
        end
      end

    end

    attr_accessor :name

    def initialize(host,port=nil)
      @host, @port = host, port
    end

    def device_type 
      'urn:Belkin:device:controllee:1'
    end

    # Turn the Switch on or off, based on its current state
    def toggle!
        on? ? off! : on!
    end

    # Turn the Switch off
    def off!     
      set_state(0)       
    end

    # Turn the Switch on
    def on!      
      set_state(1)   
    end

    # Return whether the Switch is off
    #
    # @return [Boolean]
    def off?     
      get_state == :off
    end

    # Return whether the Switch is on
    #
    # @return [Boolean]
    def on?      
      get_state == :on
    end

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
          begin
            state = get_state
            if state != old_state
              old_state = state
              yield state
            end
          rescue Exception
          end
          sleep rate
        end
      end
      puts "Monitoring #{@name} for changes"
      async ? poller : poller.join
    end

    protected

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

  end
end
