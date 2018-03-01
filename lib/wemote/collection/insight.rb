module Wemote
  module Collection

    # This class provides an extension on the basic Array object, in order to
    # facilitate group operations on a collection of Wemote::Switch instances.
    class Insight < Switch

      make :standby?

    end
  end
end
