class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def authenticate_user!
    redirect_to login_path, alert: "ログインしてください" unless current_user
  end

  def authenticate_author!
    redirect_to root_path, alert: "権限がありません" unless current_user&.author?
  end
end
