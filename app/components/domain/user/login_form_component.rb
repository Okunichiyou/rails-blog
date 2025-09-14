module Domain
  module User
    class LoginFormComponent < Domain::Base
      def initialize(resource:, resource_name:, session_path:)
        @resource = resource
        @resource_name = resource_name
        @session_path = session_path
      end
    end
  end
end
