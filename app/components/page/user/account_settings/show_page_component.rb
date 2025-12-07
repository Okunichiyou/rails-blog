module Page
  module User
    module AccountSettings
      class ShowPageComponent < ApplicationComponent
        # @rbs (user: ::User) -> void
        def initialize(user:)
          @user = user
        end
      end
    end
  end
end
