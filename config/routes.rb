Rails.application.routes.draw do
  # ====================
  # 開発用ツール
  # ====================
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # ====================
  # 基本ルート
  # ====================
  root "posts#index"
  get "up" => "rails/health#show", as: :rails_health_check

  # ====================
  # Devise設定
  # ====================
  devise_for :user, skip: :all
  devise_for :users
  devise_for :database_authentications, class_name: "User::DatabaseAuthentication", skip: :all
  devise_for :sns_credentials, class_name: "User::SnsCredential",
    path: "users/sns_credentials",
    controllers: {
      omniauth_callbacks: "users/sns_credential/omniauth_callbacks"
    }

  # 新規登録が有効な場合のみメール確認ルートを有効化
  if Rails.configuration.auth_enabled
    devise_for :confirmations, class_name: "User::Confirmation", controllers: {
      confirmations: "users/confirmations"
    }

    devise_scope :confirmation do
      get "/confirmations/sent", to: "users/confirmations#sent", as: "email_confirmation_sent"
    end
  end

  # ====================
  # 認証ルート
  # ====================
  devise_scope :database_authentication do
    get "/login", to: "users/database_authentication/sessions#new", as: :login
    post "/login", to: "users/database_authentication/sessions#create"
    delete "/logout", to: "users/database_authentication/sessions#destroy", as: :logout
  end

  # OmniAuth failure時にnew_user_session_pathが必要なためエイリアスを定義
  direct :new_user_session do
    "/login"
  end

  # ====================
  # ユーザー関連
  # ====================
  # ユーザー機能（認証・登録・設定など）
  namespace :users do
    # 新規登録・アカウント連携ルート（auth_enabled時のみ）
    if Rails.configuration.auth_enabled
      resources :database_authentications, only: [ :new, :create ] do
        collection do
          get :link_new
          post :link_create
        end
      end
      resources :sns_credential_registrations, only: [ :new, :create ]
    end

    resource :account_settings, only: [ :show ]
    resources :post_drafts, except: [ :show ]
    resources :liked_posts, only: [ :index ]
  end

  # 特定ユーザーのリソース参照
  resources :users, only: [] do
    resources :posts, only: [ :index, :edit, :destroy ], controller: "users/posts"
  end

  # ====================
  # その他リソース
  # ====================
  resources :posts, only: [ :index, :show, :create, :update ] do
    resource :like, only: [ :create, :destroy ], controller: "posts/likes"
  end
  resources :editor_images, only: [ :create ]
end
