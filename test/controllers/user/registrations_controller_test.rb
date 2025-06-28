require "test_helper"

class User::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  # =====================================
  # createアクション（確認メール送信）
  # =====================================

  test "POST /registrations/confirmation 新規メールアドレスで確認メール送信" do
    email = "new@example.com"

    assert_difference "User::Registration.count", 1 do
      post registration_confirmation_path, params: { registration: { email: email } }
    end

    assert_response :success
    assert_equal "Sending an email confirmation instruction", flash[:notice]

    registration = User::Registration.find_by(unconfirmed_email: email)
    assert_not_nil registration
    assert_not_nil registration.confirmation_token
  end

  test "POST /registrations/confirmation 既存の未確認メールアドレスで再送信" do
    User::Registration.create!(
      unconfirmed_email: "existing@example.com",
      confirmation_token: "existing_token"
    )

    assert_no_difference "User::Registration.count" do
      post registration_confirmation_path, params: { registration: { email: "existing@example.com" } }
    end

    assert_response :success
    assert_equal "Sending an email confirmation instruction", flash[:notice]
  end

  # =====================================
  # showアクション（確認完了画面）
  # =====================================

  test "GET /registrations/confirmation 有効なトークンで確認画面表示" do
    User::Registration.create!(
      unconfirmed_email: "confirm@example.com",
      confirmation_token: "valid_token"
    )

    get registration_confirmation_path, params: { confirmation_token: "valid_token" }

    assert_response :success
    assert_select "form", count: 1
  end

  test "GET /registrations/confirmation 無効なトークンでエラー" do
    get registration_confirmation_path, params: { confirmation_token: "invalid_token" }

    assert_response :success
    assert_select "form", count: 1
  end

  # =====================================
  # finishアクション（登録完了）
  # =====================================

  test "POST /registration/finish 正常な登録完了フロー" do
    User::Registration.create!(
      unconfirmed_email: "finish@example.com",
      confirmation_token: "finish_token",
      confirmation_sent_at: 1.hour.ago,
      confirmed_at: 30.minutes.ago
    )

    assert_difference [ "User.count", "User::DatabaseAuthentication.count" ], 1 do
      assert_difference "User::Registration.count", -1 do
        post finish_user_registration_path, params: {
          confirmation_token: "finish_token",
          name: "Test User",
          email: "finish@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      end
    end

    assert_redirected_to root_path

    user = User.find_by(name: "Test User")
    assert_not_nil user

    db_auth = User::DatabaseAuthentication.find_by(email: "finish@example.com")
    assert_not_nil db_auth
    assert_equal user, db_auth.user

    assert_nil User::Registration.find_by(unconfirmed_email: "finish@example.com")
  end

  test "POST /registration/finish 無効なトークンでエラー" do
    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count", "User::Registration.count" ] do
      post finish_user_registration_path, params: {
        confirmation_token: "invalid_token",
        name: "Test User",
        email: "test@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    assert_response :not_found
  end

  test "POST /registration/finish パスワード不一致でエラー" do
    User::Registration.create!(
      unconfirmed_email: "mismatch@example.com",
      confirmation_token: "mismatch_token",
      confirmation_sent_at: 1.hour.ago
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      assert_no_difference "User::Registration.count" do
        post finish_user_registration_path, params: {
          confirmation_token: "mismatch_token",
          name: "Test User",
          email: "mismatch@example.com",
          password: "password123",
          password_confirmation: "different_password"
        }
      end
    end

    assert_response :unprocessable_entity
    assert_select "form", count: 1
  end

  test "POST /registration/finish パスワードの長さ不足でエラー" do
    User::Registration.create!(
      unconfirmed_email: "short@example.com",
      confirmation_token: "short_token",
      confirmation_sent_at: 1.hour.ago
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      post finish_user_registration_path, params: {
        confirmation_token: "short_token",
        name: "Test User",
        email: "short@example.com",
        password: "123",
        password_confirmation: "123"
      }
    end

    assert_response :unprocessable_entity
  end

  test "POST /registration/finish 必須項目不足でエラー(name)" do
    User::Registration.create!(
      unconfirmed_email: "missing@example.com",
      confirmation_token: "missing_token",
      confirmation_sent_at: 1.hour.ago
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      post finish_user_registration_path, params: {
        confirmation_token: "missing_token",
        name: "",
        email: "missing@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    assert_response :unprocessable_entity
  end

  test "POST /registration/finish 必須項目不足でエラー(email)" do
    User::Registration.create!(
      unconfirmed_email: "missing@example.com",
      confirmation_token: "missing_token",
      confirmation_sent_at: 1.hour.ago
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      post finish_user_registration_path, params: {
        confirmation_token: "missing_token",
        name: "user",
        email: "",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    assert_response :unprocessable_entity
  end

  test "POST /registration/finish 必須項目不足でエラー(password)" do
    User::Registration.create!(
      unconfirmed_email: "missing@example.com",
      confirmation_token: "missing_token",
      confirmation_sent_at: 1.hour.ago
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      post finish_user_registration_path, params: {
        confirmation_token: "missing_token",
        name: "user",
        email: "missing@example.com",
        password: "",
        password_confirmation: ""
      }
    end

    assert_response :unprocessable_entity
  end
end
