class User::DatabaseAuthenticationsController < ApplicationController
  before_action :authenticate_user!, only: [ :link_new, :link_create ]

  private

  def authenticate_user!
    redirect_to login_path, alert: "ログインしてください" unless current_user
  end

  public

  def new
    confirmation_token = params[:confirmation_token]
    @form = User::DatabaseAuthenticationRegistrationForm.new(confirmation_token:)

    return if @form.valid?

    render :new, status: :unprocessable_content
  end

  def create
    form_params = params.require(:confirmation).permit(:user_name, :password, :password_confirmation, :confirmation_token)
    @form = User::DatabaseAuthenticationRegistrationForm.new(form_params)

    if @form.call
      sign_in(:user, @form.user)
      sign_in(:database_authentication, @form.user_database_authentication)
      redirect_to root_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def link_new
    confirmation_token = params[:confirmation_token]
    @form = User::DatabaseAuthenticationLinkForm.new(
      current_user: current_user,
      confirmation_token: confirmation_token
    )

    return if @form.valid?

    render :link_new, status: :unprocessable_content
  end

  def link_create
    form_params = params.require(:confirmation).permit(:password, :password_confirmation, :confirmation_token)
    @form = User::DatabaseAuthenticationLinkForm.new(
      current_user: current_user,
      **form_params
    )

    if @form.call
      sign_in(:database_authentication, @form.user_database_authentication)
      redirect_to root_path
    else
      render :link_new, status: :unprocessable_content
    end
  end
end
