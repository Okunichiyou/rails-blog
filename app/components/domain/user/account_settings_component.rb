module Domain
  module User
    class AccountSettingsComponent < ApplicationComponent
      # @rbs (user: ::User) -> void
      def initialize(user:)
        @user = user
      end

      # @rbs () -> String
      def google_oauth2_path
        sns_credential_google_oauth2_omniauth_authorize_path
      end
    end
  end
end
