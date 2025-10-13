module Page
  module User
    module Registrations
      class ShowPageComponent < Page::Base
        def initialize(form:, finish_user_registration_path:)
          @form = form
          @finish_user_registration_path = finish_user_registration_path
        end
      end
    end
  end
end
