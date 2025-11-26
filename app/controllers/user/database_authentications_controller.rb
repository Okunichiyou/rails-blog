class User::DatabaseAuthenticationsController < ApplicationController
  # @rbs () -> ActiveSupport::SafeBuffer?
  def new
    confirmation_token = params[:confirmation_token]
    @form = User::DatabaseAuthenticationRegistrationForm.new(confirmation_token:)

    return if @form.valid?

    render :new, status: :unprocessable_entity
  end

  # @rbs () -> (ActiveSupport::SafeBuffer | Integer)
  def create
    form_params = params.require(:confirmation).permit(:user_name, :password, :password_confirmation, :confirmation_token)
    @form = User::DatabaseAuthenticationRegistrationForm.new(form_params)

    if @form.call
      sign_in(:user, @form.user)
      sign_in(:database_authentication, @form.user_database_authentication)
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end
