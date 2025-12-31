Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  root "posts#index"
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :user, skip: :all
  # OmniAuth failure時にnew_user_session_pathが必要なためエイリアスを定義
  direct :new_user_session do
    "/login"
  end
  devise_for :database_authentications, class_name: "User::DatabaseAuthentication", skip: :all
  devise_for :sns_credentials, class_name: "User::SnsCredential",
    path: "users/sns_credentials",
    controllers: {
      omniauth_callbacks: "users/sns_credential/omniauth_callbacks"
    }

  devise_scope :database_authentication do
    get "/login", to: "users/database_authentication/sessions#new", as: :login
    post "/login", to: "users/database_authentication/sessions#create"
    delete "/logout", to: "users/database_authentication/sessions#destroy", as: :logout
  end
  devise_for :confirmations, class_name: "User::Confirmation", controllers: {
    confirmations: "users/confirmations"
  }
  devise_scope :confirmation do
    get "/confirmations/sent", to: "users/confirmations#sent", as: "email_confirmation_sent"
  end

  namespace :users do
    resources :database_authentications, only: [ :new, :create ] do
      collection do
        get :link_new
        post :link_create
      end
    end
    resources :sns_credential_registrations, only: [ :new, :create ]
    resource :account_settings, only: [ :show ]
    resources :post_drafts, except: [ :show ]
  end

  resources :users, only: [] do
    resources :posts, only: [ :index, :edit, :destroy ], controller: "users/posts"
  end
  resources :posts, only: [ :index, :show, :create, :update ]
  resources :editor_images, only: [ :create ]

  devise_for :users
end
