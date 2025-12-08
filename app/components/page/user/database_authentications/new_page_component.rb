module Page
  module User
    module DatabaseAuthentications
      class NewPageComponent < ApplicationComponent
        # @rbs (form: User::DatabaseAuthenticationRegistrationForm, create_database_authentication_path: String) -> void
        def initialize(form:, create_database_authentication_path:)
          @form = form
          @create_database_authentication_path = create_database_authentication_path
        end
      end
    end
  end
end
