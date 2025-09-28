module Page
  module User
    module Registrations
      class NewPageComponent < Page::Base
        def initialize(form:, confirmation_path:, resource_name: :registration)
          @form = form
          @confirmation_path = confirmation_path
          @resource_name = resource_name
        end
      end
    end
  end
end
