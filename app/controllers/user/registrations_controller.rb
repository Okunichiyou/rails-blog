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
      @user = User.new
      @user_database_authentication = User::DatabaseAuthentication.new
      return render :show
    end
  end

  def sent
  end

  def finish
    found_resource = resource_class.find_by_confirmation_token(params[:confirmation_token])

    if found_resource.nil?
      head :not_found
      return
    end

    self.resource = found_resource

    unless resource.confirmed?
      @user = User.new
      @user_database_authentication = User::DatabaseAuthentication.new
      return render :show, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      @user = User.new(name: params[:name])
      @user_database_authentication = User::DatabaseAuthentication.new(user: @user, email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation])
      @user.save!
      @user_database_authentication.save!
      self.resource.destroy!
    end

    sign_in(:user, @user)
    sign_in(:database_authentication, @user_database_authentication)

    redirect_to root_path
  rescue
    render :show, status: :unprocessable_entity
  end
end
