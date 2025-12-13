module Domain
  module User
    class SnsCredentialRegistrationFormComponent < ApplicationComponent
      # @rbs (form: User::SnsCredentialRegistrationForm) -> void
      def initialize(form:)
        @form = form
      end
    end
  end
end
