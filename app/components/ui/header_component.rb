module Ui
  class HeaderComponent < ApplicationComponent
    # @rbs (?login_user: nil | User) -> void
    def initialize(login_user: nil)
      @login_user = login_user
    end
  end
end
