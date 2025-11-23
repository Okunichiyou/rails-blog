module Page
  module User
    module Confirmations
      class ShowPageComponent < ApplicationComponent
        def initialize(resource:, **html_options)
          @resource = resource
          @html_options = html_options
        end
      end
    end
  end
end
