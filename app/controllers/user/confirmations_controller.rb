class User::ConfirmationsController < Devise::ConfirmationsController
  def new
    @form = User::EmailConfirmationForm.new
    respond_with(@form)
  end

  def create
    @form = User::EmailConfirmationForm.new(params.require(:confirmation).permit(:email))
    if @form.call
      super do
        return redirect_to email_confirmation_sent_path
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def sent
  end

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      # 他の認証手段を持っているユーザーが新たにメール認証をアカウントに追加する場合
      if current_user.present?
        redirect_to link_new_user_database_authentications_path(confirmation_token: resource.confirmation_token)
      else
        redirect_to new_user_database_authentication_path(confirmation_token: resource.confirmation_token)
      end
    else
      respond_with(resource, status: :unprocessable_entity)
    end
  end
end
