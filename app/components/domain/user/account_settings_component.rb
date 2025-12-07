module Domain
  module User
    class AccountSettingsComponent < ApplicationComponent
      # @rbs (user: ::User) -> void
      def initialize(user:)
        @user = user
      end
    end
  end
end
