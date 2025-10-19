Rails.application.routes.draw do
  root "home#index"
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :user, skip: :all
  devise_for :database_authentications, class_name: "User::DatabaseAuthentication", controllers: {
    sessions: "user/database_authentication/sessions"
  }
  devise_for :confirmations, class_name: "User::Confirmation", controllers: {
    confirmations: "user/confirmations"
  }
  devise_scope :confirmation do
    get "/confirmations/sent", to: "user/confirmations#sent", as: "email_confirmation_sent"
  end

  namespace :user do
    resources :database_authentications, only: [ :new, :create ]
  end

  devise_for :users
end
