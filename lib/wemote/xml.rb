module Wemote
  module XML
    class << self
      xml_path = File.join(File.dirname(__FILE__),'/../../xml')
      TEMPLATES = {
        get_binary_state: File.read(File.join(xml_path,'get_binary_state.xml')),
        set_binary_state: File.read(File.join(xml_path,'set_binary_state.xml'))
      }

      # @return [String] The required XML body for a Wemo binary state request
      def get_binary_state
        TEMPLATES[:get_binary_state]
      end

      # @param [Integer] state Either 1 or 0, for off and on respectively
      # @return [String] The required XML body for a Wemo binary state set request
      def set_binary_state(state)
        TEMPLATES[:set_binary_state].gsub("{{1}}",state.to_s)
      end

    end
  end
end
