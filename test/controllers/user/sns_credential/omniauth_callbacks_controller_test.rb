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

  test "Google認証成功 - 新規ユーザー作成" do
    OmniAuth.config.mock_auth[:google_oauth2] = build_auth_hash

    assert_difference [ "User.count", "User::SnsCredential.count" ], 1 do
      post sns_credential_google_oauth2_omniauth_callback_path
    end

    assert_redirected_to root_path
    assert_not_nil session["warden.user.user.key"]

    created_user = User.last
    assert_equal "Test User", created_user.name

    created_credential = User::SnsCredential.last
    assert_equal "google", created_credential.provider
    assert_equal "123456789", created_credential.uid
    assert_equal "test@example.com", created_credential.email
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
    assert_equal "既に同じメールアドレスでアカウントが連携されています", flash[:alert]
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
    assert_equal "既に同じメールアドレスでアカウントが連携されています", flash[:alert]
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
  # failureアクション（認証エラー）
  # =====================================

  test "認証失敗時のエラーハンドリング" do
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

    get sns_credential_google_oauth2_omniauth_callback_path

    assert_redirected_to root_path
    assert_match(/Authentication failed/, flash[:alert])
  end
end
