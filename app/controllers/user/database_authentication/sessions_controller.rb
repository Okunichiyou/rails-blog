class User::DatabaseAuthentication::SessionsController < Devise::SessionsController
  # @rbs () -> Integer?
  def create
    super do |resource|
      sign_in(:user, resource.user)
    end
  end
end
