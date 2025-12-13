module Domain
  module User
    class DatabaseAuthenticationLinkFormComponent < ApplicationComponent
      # @rbs (form: User::DatabaseAuthenticationLinkForm) -> void
      def initialize(form:)
        @form = form
      end
    end
  end
end
