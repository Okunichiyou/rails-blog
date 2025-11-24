module Domain
  module User
    class SnsCredentialRegistrationFormComponent < ApplicationComponent
      def initialize(form:, create_sns_credential_registration_path:)
        @form = form
        @create_sns_credential_registration_path = create_sns_credential_registration_path
      end
    end
  end
end
