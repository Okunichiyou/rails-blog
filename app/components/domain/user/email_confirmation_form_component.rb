module Domain
  module User
    class EmailConfirmationFormComponent < ApplicationComponent
      # @rbs (form: User::EmailConfirmationForm, resource_name: Symbol) -> void
      def initialize(form:, resource_name:)
        @form = form
        @resource_name = resource_name
      end
    end
  end
end
