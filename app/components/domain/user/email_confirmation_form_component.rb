module Domain
  module User
    class EmailConfirmationFormComponent < Domain::Base
      def initialize(resource:, resource_name:, confirmation_path:)
        @resource = resource
        @resource_name = resource_name
        @confirmation_path = confirmation_path
      end
    end
  end
end
