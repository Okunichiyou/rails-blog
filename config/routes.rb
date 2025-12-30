Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  root "home#index"
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :user, skip: :all
  devise_for :database_authentications, class_name: "User::DatabaseAuthentication", skip: :all
  devise_for :sns_credentials, class_name: "User::SnsCredential",
    path: "user/sns_credentials",
    controllers: {
      omniauth_callbacks: "user/sns_credential/omniauth_callbacks"
    }

  devise_scope :database_authentication do
    get "/login", to: "user/database_authentication/sessions#new", as: :login
    post "/login", to: "user/database_authentication/sessions#create"
    delete "/logout", to: "user/database_authentication/sessions#destroy", as: :logout
  end
  devise_for :confirmations, class_name: "User::Confirmation", controllers: {
    confirmations: "user/confirmations"
  }
  devise_scope :confirmation do
    get "/confirmations/sent", to: "user/confirmations#sent", as: "email_confirmation_sent"
  end

  namespace :user do
    resources :database_authentications, only: [ :new, :create ] do
      collection do
        get :link_new
        post :link_create
      end
    end
    resources :sns_credential_registrations, only: [ :new, :create ]
    resource :account_settings, only: [ :show ]
  end

  resources :post_drafts, except: [ :show ]
  resources :posts, only: [ :create, :update ]

  devise_for :users
end
