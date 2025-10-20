module Domain
  module User
    class DatabaseAuthenticationRegistrationFormComponent < Domain::Base
      def initialize(form:, create_database_authentication_path:)
        @form = form
        @create_database_authentication_path = create_database_authentication_path
      end
    end
  end
end
