class Users::DatabaseAuthentication::SessionsController < Devise::SessionsController
  def create
    super do |resource|
      sign_in(:user, resource.user)
    end
  end
end
