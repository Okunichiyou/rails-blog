class User::SnsCredential::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: %i[google_oauth2]

  def google_oauth2
    if current_user
      # ログイン済み → アカウント連携フロー
      handle_account_linking(:google)
    else
      # 未ログイン → 既存の新規登録・ログインフロー
      callback_for(:google)
    end
  end

  def failure
    error_type = request.env["omniauth.error.type"]
    error = request.env["omniauth.error"]
    strategy = request.env["omniauth.error.strategy"]

    Rails.logger.error "OmniAuth Error Type: #{error_type}"
    Rails.logger.error "OmniAuth Error: #{error.inspect}"
    Rails.logger.error "OmniAuth Strategy: #{strategy&.name}"

    redirect_to login_path, alert: "Authentication failed: #{error_type}"
  end

  private

  def handle_account_linking(provider)
    auth = request.env["omniauth.auth"]
    omniauth_data = User::OmniauthData.from_omniauth(auth)

    result = User::SnsAuthenticationDomainService.link_to_existing_user(omniauth_data, current_user)

    if result.success?
      redirect_to root_path, notice: "Googleアカウントを連携しました"
    else
      redirect_to root_path, alert: result.message
    end
  end

  def callback_for(provider)
    auth = request.env["omniauth.auth"]
    omniauth_data = User::OmniauthData.from_omniauth(auth)

    result = User::SnsAuthenticationDomainService.authenticate_or_create(omniauth_data)

    if result.success?
      @user = result.user
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider.to_s.capitalize) if is_navigational_format?
    elsif result.pending_registration?
      # 新規ユーザーの場合：ユーザー名編集フォームへリダイレクト
      redirect_to new_user_sns_credential_registration_path(token: result.token)
    else
      redirect_to login_path, alert: result.message
    end
  end
end
