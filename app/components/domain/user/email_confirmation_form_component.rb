module Domain
  module User
    class EmailConfirmationFormComponent < ApplicationComponent
      # @rbs (form: User::EmailConfirmationForm, confirmation_path: String, resource_name: Symbol) -> void
      def initialize(form:, confirmation_path:, resource_name:)
        @form = form
        @confirmation_path = confirmation_path
        @resource_name = resource_name
      end
    end
  end
end
