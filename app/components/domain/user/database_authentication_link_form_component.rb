module Domain
  module User
    class DatabaseAuthenticationLinkFormComponent < ApplicationComponent
      # @rbs (form: User::DatabaseAuthenticationLinkForm, create_database_authentication_link_path: String) -> void
      def initialize(form:, create_database_authentication_link_path:)
        @form = form
        @create_database_authentication_link_path = create_database_authentication_link_path
      end
    end
  end
end
