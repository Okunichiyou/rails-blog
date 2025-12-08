module Page
  module User
    module Confirmations
      class ShowPageComponent < ApplicationComponent
        # @rbs (resource: User::Confirmation) -> void
        def initialize(resource:)
          @resource = resource
        end
      end
    end
  end
end
