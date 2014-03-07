module Wemote
  module Collection

    # This class provides an extension on the basic Array object, in order to
    # facilitate group operations on a collection of Wemote::Switch instances.
    class Switch < Array

      class << self

        private

        # @macro [attach] container.increment
        #   @method $1()
        #   Calls {Wemote::Switch#$1} on all containing elements and return the results in an
        #   array
        #   @return [Array]
        def self.make(name)
          define_method(name){map{|s|s.send(name)}}
        end

      end

      make :toggle!
      make :off!
      make :off?
      make :on!
      make :on?

    end
  end
end
