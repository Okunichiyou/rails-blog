module Domain
  module User
    class DatabaseAuthenticationRegistrationFormComponent < Domain::Base
      def initialize(form:, finish_user_registration_path:)
        @form = form
        @finish_user_registration_path = finish_user_registration_path
      end
    end
  end
end
