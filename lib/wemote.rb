require_relative './wemote/version'

module Wemote
  require_relative './wemote/collection/switch'
  require_relative './wemote/collection/insight'
  require_relative './wemote/switch'
  require_relative './wemote/insight'
  require_relative './wemote/client'
  require_relative './wemote/xml'

  class << self

    def discover
      Wemote::Switch.send(:discover)
    end

  end
end
