require_relative './wemote/version'

module Wemote
  require_relative './wemote/collection/switch'
  require_relative './wemote/switch'
  require_relative './wemote/client'
  require_relative './wemote/xml'

  class << self

    # Handles all upnp detection, and returns the socket used.
    #
    # This is necessary when Wemote is used with other libraries that rely on
    # updp discovery (see http://github.com/gisikw/huemote), as the socket is
    # not always closed immediately. In practice, you likely will only use this
    # method in the following instance:
    #
    # @example Handle upnp discovery for both Huemote and Wemote
    #   sock = Wemote.discover
    #   Huemote.discover(sock)
    #   sock.close
    #
    # @example Or more concisely
    #   Huemote.discover(Wemote.discover).close
    #
    # @param [UDPSocket] socket   a socket already set for ssdp discovery.
    # @return [UDPSocket]

    def discover(socket=nil)
      Wemote::Switch.send(:discover,socket)
    end

  end
end
