class Users::SnsCredentialRegistrationsController < ApplicationController
  def new
    token = params[:token]
    pending_credential = User::PendingSnsCredential.find_by(token: token)
    @form = User::SnsCredentialRegistrationForm.new(token: token, user_name: pending_credential&.name)

    # トークンが無効な場合はエラー画面を表示
    return if @form.valid?(:token_validation_only)

    render :new, status: :unprocessable_content
  end

  def create
    form_params = params.require(:user_sns_credential_registration).permit(:user_name, :token)
    @form = User::SnsCredentialRegistrationForm.new(form_params)

    if @form.save
      sign_in(:user, @form.user)
      redirect_to root_path, notice: "アカウントの登録が完了しました"
    else
      render :new, status: :unprocessable_content
    end
  end
end
