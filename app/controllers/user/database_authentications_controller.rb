class User::DatabaseAuthenticationsController < ApplicationController
  def new
    confirmation_token = params[:confirmation_token]
    found_resource = User::Confirmation.find_by_confirmation_token(confirmation_token)

    if found_resource.nil?
      head :not_found
      return
    end

    unless found_resource.confirmed?
      head :unprocessable_entity
      return
    end

    @form = User::DatabaseAuthenticationRegistrationForm.new(
      email: found_resource.email,
      confirmation_token: found_resource.confirmation_token
    )
  end

  def create
    confirmation_token = params.dig(:confirmation, :confirmation_token)
    found_resource = User::Confirmation.find_by_confirmation_token(confirmation_token)

    if found_resource.nil?
      head :not_found
      return
    end

    unless found_resource.confirmed?
      @form = User::DatabaseAuthenticationRegistrationForm.new(
        email: found_resource.email,
        confirmation_token: found_resource.confirmation_token
      )
      return render :new, status: :unprocessable_entity
    end

    form_params = params.require(:confirmation).permit(:user_name, :password, :password_confirmation, :confirmation_token)
    form_params[:email] = found_resource.email
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
