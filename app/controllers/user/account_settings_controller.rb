class User::AccountSettingsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  private

  def authenticate_user!
    redirect_to login_path, alert: "ログインしてください" unless current_user
  end
end
