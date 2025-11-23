module Ui
  class HeaderComponent < ApplicationComponent
    def initialize(login_user: nil, **html_options)
      @login_user = login_user
      @html_options = html_options
    end
  end
end
