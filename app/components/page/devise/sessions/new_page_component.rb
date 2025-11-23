module Page
  module Devise
    module Sessions
      class NewPageComponent < Page::Base
        def initialize(resource:, resource_name:, login_path:)
          @resource = resource
          @resource_name = resource_name
          @login_path = login_path
        end
      end
    end
  end
end
