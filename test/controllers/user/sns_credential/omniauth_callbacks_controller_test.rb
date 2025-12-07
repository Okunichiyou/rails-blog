require "test_helper"

class User::SnsCredential::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    @valid_auth_hash = {
      provider: "google",
      uid: "123456789",
      info: {
        name: "Test User",
        email: "test@example.com"
      }
    }
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  private

  def build_auth_hash(**overrides)
    hash = @valid_auth_hash.deep_dup
    overrides.each do |key, value|
      keys = key.to_s.split(".")
      target = keys[0..-2].reduce(hash) { |h, k| h[k.to_sym] }
      target[keys.last.to_sym] = value
    end
    OmniAuth::AuthHash.new(hash)
  end

  # =====================================
  # google_oauth2アクション（Google認証コールバック）
  # =====================================

  test "Google認証成功 - 新規ユーザーの場合はPendingSnsCredentialを作成して登録フォームへリダイレクト" do
    OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash

    assert_no_difference [ "User.count", "User::SnsCredential.count" ] do
      assert_difference "User::PendingSnsCredential.count", 1 do
        post sns_credential_google_oauth2_omniauth_callback_path
      end
    end

    # 登録フォームへリダイレクトされることを確認
    assert_response :redirect
    assert_match %r{/user/sns_credential_registrations/new\?token=}, response.location

    # PendingSnsCredentialが正しく作成されていることを確認
    pending = User::PendingSnsCredential.last
    assert_equal "google", pending.provider
    assert_equal "123456789", pending.uid
    assert_equal "test@example.com", pending.email
    assert_equal "Test User", pending.name
  end

  test "Google認証成功 - 既存ユーザーでログイン" do
    user = User.create!(name: "Existing User")
    User::SnsCredential.create!(
      user: user,
      provider: "google",
      uid: "123456789",
      email: "existing@example.com"
    )

    OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash(
      "info.name": "Existing User",
      "info.email": "existing@example.com"
    )

    assert_no_difference [ "User.count", "User::SnsCredential.count" ] do
      post sns_credential_google_oauth2_omniauth_callback_path
    end

    assert_redirected_to root_path
    assert_not_nil session["warden.user.user.key"]
  end

  test "Google認証失敗 - メールアドレスが既にDatabaseAuthenticationで使用されている" do
    user = User.create!(name: "Existing User")
    User::DatabaseAuthentication.create!(
      user: user,
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash

    assert_no_difference [ "User.count", "User::SnsCredential.count" ] do
      post sns_credential_google_oauth2_omniauth_callback_path
    end

    assert_redirected_to login_path
    assert_equal "既に同じメールアドレスでアカウントが連携されています。このメールアドレスでSNS認証を利用するには、一度ログインしてからアカウント連携を行ってください。", flash[:alert]
  end

  test "Google認証失敗 - メールアドレスが既にSnsCredentialで使用されている" do
    user = User.create!(name: "Existing User")
    User::SnsCredential.create!(
      user: user,
      provider: "github",
      uid: "987654321",
      email: "test@example.com"
    )

    OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash

    assert_no_difference [ "User.count", "User::SnsCredential.count" ] do
      post sns_credential_google_oauth2_omniauth_callback_path
    end

    assert_redirected_to login_path
    assert_equal "既に同じメールアドレスでアカウントが連携されています。このメールアドレスでSNS認証を利用するには、一度ログインしてからアカウント連携を行ってください。", flash[:alert]
  end

  test "Google認証失敗 - 認証データが不完全（info.nameがnil）" do
    OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash("info.name": nil)

    assert_no_difference [ "User.count", "User::SnsCredential.count" ] do
      post sns_credential_google_oauth2_omniauth_callback_path
    end

    assert_redirected_to login_path
    assert_includes flash[:alert], "Name can't be blank"
  end

  test "Google認証失敗 - 認証データが不完全（info.emailがnil）" do
    OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash("info.email": nil)

    assert_no_difference [ "User.count", "User::SnsCredential.count" ] do
      post sns_credential_google_oauth2_omniauth_callback_path
    end

    assert_redirected_to login_path
    assert_includes flash[:alert], "Email can't be blank"
  end

  # =====================================
  # アカウント連携（ログイン済みユーザー）
  # =====================================

  test "ログイン済みユーザーがGoogleアカウントを連携できる" do
    # ログイン
    post login_path, params: {
      database_authentication: {
        email: "db_auth@example.com",
        password: "password123"
      }
    }

    OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash

    assert_difference "User::SnsCredential.count", 1 do
      assert_no_difference "User.count" do
        post sns_credential_google_oauth2_omniauth_callback_path
      end
    end

    assert_redirected_to root_path
    assert_equal "Googleアカウントを連携しました", flash[:notice]

    # 正しく連携されていることを確認
    credential = User::SnsCredential.find_by(provider: "google", uid: "123456789")
    assert_equal users(:db_auth_user), credential.user
  end

  test "ログイン済みユーザー：既に別のユーザーに紐づいているGoogleアカウントの場合は連携失敗" do
    other_user = users(:one)
    User::SnsCredential.create!(
      user: other_user,
      provider: "google",
      uid: "123456789",
      email: "test@example.com"
    )

    # ログイン
    post login_path, params: {
      database_authentication: {
        email: "db_auth@example.com",
        password: "password123"
      }
    }

    OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash

    assert_no_difference [ "User.count", "User::SnsCredential.count" ] do
      post sns_credential_google_oauth2_omniauth_callback_path
    end

    assert_redirected_to root_path
    assert_not_nil flash[:alert]
  end

  test "ログイン済みユーザー：既に同じユーザーに紐づいているGoogleアカウントの場合は連携失敗" do
    user = users(:db_auth_user)
    User::SnsCredential.create!(
      user: user,
      provider: "google",
      uid: "123456789",
      email: "test@example.com"
    )

    # ログイン
    post login_path, params: {
      database_authentication: {
        email: "db_auth@example.com",
        password: "password123"
      }
    }

    OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash

    assert_no_difference [ "User.count", "User::SnsCredential.count" ] do
      post sns_credential_google_oauth2_omniauth_callback_path
    end

    assert_redirected_to root_path
    assert_not_nil flash[:alert]
  end

  # =====================================
  # failureアクション（認証エラー）
  # =====================================

  test "認証失敗時のエラーハンドリング" do
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

    get sns_credential_google_oauth2_omniauth_callback_path

    assert_redirected_to login_path
    assert_match(/Authentication failed/, flash[:alert])
  end
end
