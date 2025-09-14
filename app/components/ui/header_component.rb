module Ui
  class HeaderComponent < Ui::Base
    def initialize(login_user: nil, html_options: {})
      @html_options = html_options
      @login_user = login_user
    end
  end
end
