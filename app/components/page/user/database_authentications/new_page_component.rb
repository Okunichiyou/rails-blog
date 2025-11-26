module Page
  module User
    module DatabaseAuthentications
      class NewPageComponent < ApplicationComponent
        # @rbs (form: User::DatabaseAuthenticationRegistrationForm, create_database_authentication_path: String, **nil) -> void
        def initialize(form:, create_database_authentication_path:, **html_options)
          @form = form
          @create_database_authentication_path = create_database_authentication_path
          @html_options = html_options
        end
      end
    end
  end
end
