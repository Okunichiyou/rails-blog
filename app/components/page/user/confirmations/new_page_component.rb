module Page
  module User
    module Confirmations
      class NewPageComponent < ApplicationComponent
        def initialize(form:, confirmation_path:, resource_name: :confirmation, **html_options)
          @form = form
          @confirmation_path = confirmation_path
          @resource_name = resource_name
          @html_options = html_options
        end
      end
    end
  end
end
