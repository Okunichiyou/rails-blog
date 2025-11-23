module Domain
  module User
    class LoginFormComponent < ApplicationComponent
      def initialize(resource:, resource_name:, login_path:)
        @resource = resource
        @resource_name = resource_name
        @login_path = login_path
      end
    end
  end
end
