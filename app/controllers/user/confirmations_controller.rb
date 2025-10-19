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

  def show
    super do
      return redirect_to new_user_database_authentication_path(confirmation_token: resource.confirmation_token)
    end
  end

  def sent
  end
end
