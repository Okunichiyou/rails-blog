module Page
  module Devise
    module Sessions
      class NewPageComponent < ApplicationComponent
        # @rbs (resource: User::DatabaseAuthentication, resource_name: Symbol, login_path: String, **nil) -> void
        def initialize(resource:, resource_name:, login_path:, **html_options)
          @resource = resource
          @resource_name = resource_name
          @login_path = login_path
          @html_options = html_options
        end
      end
    end
  end
end
