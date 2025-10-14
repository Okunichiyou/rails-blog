class User::RegistrationsController < Devise::ConfirmationsController
  def new
    @form = User::EmailConfirmationForm.new
    respond_with(@form)
  end

  def create
    @form = User::EmailConfirmationForm.new(params.require(:registration).permit(:email))
    if @form.call
      super do
        return redirect_to registration_confirmation_sent_path
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    super do
      @form = User::DatabaseAuthenticationRegistrationForm.new(
        email: resource.email,
        confirmation_token: resource.confirmation_token
      )
      return render :show
    end
  end

  def sent
  end

  def finish
    confirmation_token = params.dig(:registration, :confirmation_token)
    found_resource = resource_class.find_by_confirmation_token(confirmation_token)
    if found_resource.nil?
      head :not_found
      return
    end

    self.resource = found_resource

    unless resource.confirmed?
      @form = User::DatabaseAuthenticationRegistrationForm.new(
        email: resource.email,
        confirmation_token: resource.confirmation_token
      )
      return render :show, status: :unprocessable_entity
    end

    form_params = params.require(:registration).permit(:user_name, :password, :password_confirmation, :confirmation_token)
    form_params[:email] = resource.email
    @form = User::DatabaseAuthenticationRegistrationForm.new(form_params)

    if @form.call
      sign_in(:user, @form.user)
      sign_in(:database_authentication, @form.user_database_authentication)
      redirect_to root_path
    else
      render :show, status: :unprocessable_entity
    end
  end
end
