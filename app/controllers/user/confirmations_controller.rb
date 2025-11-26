class User::ConfirmationsController < Devise::ConfirmationsController
  def new
    @form = User::EmailConfirmationForm.new
    respond_with(@form)
  end

  # @rbs () -> (ActiveSupport::SafeBuffer | Integer)
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

  # @rbs () -> (Integer | ActiveSupport::SafeBuffer)
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      redirect_to new_user_database_authentication_path(confirmation_token: resource.confirmation_token)
    else
      respond_with(resource, status: :unprocessable_entity)
    end
  end
end
