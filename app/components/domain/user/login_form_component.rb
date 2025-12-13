module Domain
  module User
    class LoginFormComponent < ApplicationComponent
      # @rbs (resource: User::DatabaseAuthentication, resource_name: Symbol) -> void
      def initialize(resource:, resource_name:)
        @resource = resource
        @resource_name = resource_name
      end
    end
  end
end
