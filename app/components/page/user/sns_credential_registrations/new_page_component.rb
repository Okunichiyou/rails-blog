module Page
  module User
    module SnsCredentialRegistrations
      class NewPageComponent < ApplicationComponent
        # @rbs (form: User::SnsCredentialRegistrationForm, create_sns_credential_registration_path: String, **nil) -> void
        def initialize(form:, create_sns_credential_registration_path:, **html_options)
          @form = form
          @create_sns_credential_registration_path = create_sns_credential_registration_path
          @html_options = html_options
        end
      end
    end
  end
end
