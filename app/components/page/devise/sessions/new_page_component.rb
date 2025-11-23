module Page
  module Devise
    module Sessions
      class NewPageComponent < ApplicationComponent
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
