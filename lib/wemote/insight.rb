require 'socket'
require 'ipaddr'
require 'timeout'

module Wemote

  # This class encapsulates an individual Wemo Insight. It provides methods for
  # getting and setting the insight's state, as well as a {#toggle!} method for
  # convenience. Finally, it provides the {#poll} method, which accepts a block
  # to be executed any time the insight changes state.
  class Insight < Switch

    GET_HEADERS_POWER = {
      "SOAPACTION"   => '"urn:Belkin:service:insight:1#GetInsightParams"',
      "Content-type" => 'text/xml; charset="utf-8"'
    }

    class << self

      def device_type
        'urn:Belkin:device:insight:1'
      end

      # Returns all Insight detected on the local network
      #
      # @param [Boolean] refresh Refresh and redetect Insight
      # @return [Array] all Insight on the network
      def all(refresh=false)
        @insights = nil if refresh
        @insights ||= Wemote::Collection::Insight.new(discover)
      end

    end

    def initialize(host,port=nil)
      super(host, port)
    end

    # Turn the Insight on or off, based on its current state
    def toggle!  
      on? or standby? ? off! : on!;   
    end

    # Return whether the Insight is standby
    #
    # @return [Boolean]
    def standby?
      get_state == :standby;   
    end

    def power
      get_insight_params()[:power]
    end

    private

    def get_state
      response = begin
        client.post("http://#{@host}:#{@port}/upnp/control/basicevent1",Wemote::XML.get_binary_state,GET_HEADERS)
      rescue Exception
        client.post("http://#{@host}:#{@port}/upnp/control/basicevent1",Wemote::XML.get_binary_state,GET_HEADERS)
      end
      case response.body.match(/<BinaryState>(\d)<\/BinaryState>/)[1]
        when '0'
          :off
        when '1'
          :on
        when '8'
          :standby
      end
    end

    def get_insight_params
      response = begin
        client.post("http://#{@host}:#{@port}/upnp/control/insight1",Wemote::XML.get_insight_params,GET_HEADERS_POWER)
      rescue Exception
        client.post("http://#{@host}:#{@port}/upnp/control/insight1",Wemote::XML.get_insight_params,GET_HEADERS_POWER)
      end
      params = response.body.match(/<InsightParams>(.*)<\/InsightParams>/)[1].split('|')
      {
        value: (params[0].to_i == 0 ? :off : :on),
        energy: (params[8].to_i / 60000000.0).ceil,
        power: (params[7].to_i / 1000.0).round,
        on_today: (params[3].to_i / 60.0).floor
      }      
    end


  end
end
