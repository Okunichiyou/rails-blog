module Page
  module Devise
    module Sessions
      class NewPageComponent < Page::Base
        def initialize(resource:, resource_name:, session_path:)
          @resource = resource
          @resource_name = resource_name
          @session_path = session_path
        end
      end
    end
  end
end
