module Domain
  module User
    class DatabaseAuthenticationRegistrationFormComponent < ApplicationComponent
      # @rbs (form: User::DatabaseAuthenticationRegistrationForm) -> void
      def initialize(form:)
        @form = form
      end
    end
  end
end
