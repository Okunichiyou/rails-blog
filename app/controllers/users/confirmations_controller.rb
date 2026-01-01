class Users::ConfirmationsController < Devise::ConfirmationsController
  def new
    @form = User::EmailConfirmationForm.new
    respond_with(@form)
  end

  def create
    @form = User::EmailConfirmationForm.new(resource_params)
    if @form.save
      super do
        return redirect_to email_confirmation_sent_path
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def sent
  end

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      # 他の認証手段を持っているユーザーが新たにメール認証をアカウントに追加する場合
      if current_user.present?
        redirect_to link_new_users_database_authentications_path(confirmation_token: resource.confirmation_token)
      else
        redirect_to new_users_database_authentication_path(confirmation_token: resource.confirmation_token)
      end
    else
      respond_with(resource, status: :unprocessable_content)
    end
  end

  private

  def resource_params
    params.expect(user_email_confirmation: %i[email])
  end
end
