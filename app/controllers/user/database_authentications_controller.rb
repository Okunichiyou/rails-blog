class User::DatabaseAuthenticationsController < ApplicationController
  def new
    confirmation_token = params[:confirmation_token]
    @form = User::DatabaseAuthenticationRegistrationForm.new(confirmation_token:)

    case @form.validate_token
    when :not_found
      head :not_found
    when :unprocessable_entity
      head :unprocessable_entity
    end
  end

  def create
    confirmation_token = params.dig(:confirmation, :confirmation_token)
    @form = User::DatabaseAuthenticationRegistrationForm.new(confirmation_token:)

    case @form.validate_token
    when :not_found
      return head :not_found
    when :unprocessable_entity
      return render :new, status: :unprocessable_entity
    end

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
