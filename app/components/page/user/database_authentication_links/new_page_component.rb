module Page
  module User
    module DatabaseAuthenticationLinks
      class NewPageComponent < ApplicationComponent
        # @rbs (form: User::DatabaseAuthenticationLinkForm, create_database_authentication_link_path: String, **nil) -> void
        def initialize(form:, create_database_authentication_link_path:, **html_options)
          @form = form
          @create_database_authentication_link_path = create_database_authentication_link_path
          @html_options = html_options
        end
      end
    end
  end
end
