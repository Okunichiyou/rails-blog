module Page
  module User
    module Confirmations
      class ShowPageComponent < Page::Base
        def initialize(resource:)
          @resource = resource
        end
      end
    end
  end
end
