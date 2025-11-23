module Domain
  module User
    class EmailConfirmationFormComponent < ApplicationComponent
      def initialize(form:, confirmation_path:, resource_name:)
        @form = form
        @confirmation_path = confirmation_path
        @resource_name = resource_name
      end
    end
  end
end
