module Page
  module User
    module Confirmations
      class NewPageComponent < ApplicationComponent
        # @rbs (form: User::EmailConfirmationForm, confirmation_path: String, ?resource_name: Symbol) -> void
        def initialize(form:, confirmation_path:, resource_name: :confirmation)
          @form = form
          @confirmation_path = confirmation_path
          @resource_name = resource_name
        end
      end
    end
  end
end
