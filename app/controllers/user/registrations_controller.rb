class User::RegistrationsController < Devise::ConfirmationsController
  def create
    user_registration = User::Registration.find_or_initialize_by(unconfirmed_email: params[:registration][:email])
    if user_registration.save
      super do
        flash[:notice] = "Sending an email confirmation instruction"
        return redirect_to new_registration_confirmation_path
      end
    else
      respond_with(user_registration)
    end
  end

  def show
    super do
      @user = User.new
      @user_database_authentication = User::DatabaseAuthentication.new
      return render :show
    end
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
