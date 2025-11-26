module Page
  module User
    module Confirmations
      class ShowPageComponent < ApplicationComponent
        # @rbs (resource: User::Confirmation, **nil) -> void
        def initialize(resource:, **html_options)
          @resource = resource
          @html_options = html_options
        end
      end
    end
  end
end
