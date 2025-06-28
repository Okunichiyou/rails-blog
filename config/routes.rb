Rails.application.routes.draw do
  root "home#index"
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :user, skip: :all
  devise_for :database_authentications, class_name: "User::DatabaseAuthentication", controllers: {
    sessions: "user/database_authentication/sessions"
  }
  devise_for :registrations, class_name: "User::Registration", controllers: {
    confirmations: "user/registrations"
  }
  devise_scope :registration do
    post "/registration/finish", to: "user/registrations#finish",  as: "finish_user_registration"
  end
  devise_for :users
end
