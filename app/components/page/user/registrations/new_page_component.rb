module Page
  module User
    module Registrations
      class NewPageComponent < Page::Base
        def initialize(resource:, resource_name:, confirmation_path:)
          @resource = resource
          @resource_name = resource_name
          @confirmation_path = confirmation_path
        end
      end
    end
  end
end
