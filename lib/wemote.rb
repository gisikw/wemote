require_relative './wemote/version'

module Wemote
  require_relative './wemote/switch'
  require_relative './wemote/client'
  require_relative './wemote/xml'

  class << self
    def discover(socket=nil)
      Wemote::Switch.discover(socket)
    end
  end
end
