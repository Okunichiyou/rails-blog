require "test_helper"

class User::DatabaseAuthenticationsControllerTest < ActionDispatch::IntegrationTest
  # =====================================
  # newアクション（登録フォーム表示）
  # =====================================

  test "GET /user/database_authentications/new 有効なトークンで登録フォーム表示" do
    User::Confirmation.create!(
      email: "new@example.com",
      confirmation_token: "valid_token",
      confirmation_sent_at: 1.hour.ago,
      confirmed_at: 30.minutes.ago
    )

    get new_user_database_authentication_path(confirmation_token: "valid_token")

    assert_response :success
    assert_select "form", count: 1
  end

  test "GET /user/database_authentications/new 無効なトークンでエラー" do
    get new_user_database_authentication_path(confirmation_token: "invalid_token")

    assert_response :not_found
  end

  test "GET /user/database_authentications/new 未確認のトークンでエラー" do
    User::Confirmation.create!(
      unconfirmed_email: "unconfirmed@example.com",
      confirmation_token: "unconfirmed_token",
      confirmation_sent_at: 10.minutes.ago
    )

    get new_user_database_authentication_path(confirmation_token: "unconfirmed_token")

    assert_response :unprocessable_entity
  end

  # =====================================
  # createアクション（登録完了）
  # =====================================

  test "POST /user/database_authentications 正常な登録完了フロー" do
    User::Confirmation.create!(
      email: "finish@example.com",
      confirmation_token: "finish_token",
      confirmation_sent_at: 1.hour.ago,
      confirmed_at: 30.minutes.ago
    )

    assert_difference [ "User.count", "User::DatabaseAuthentication.count" ], 1 do
      assert_difference "User::Confirmation.count", -1 do
        post user_database_authentications_path, params: {
          confirmation: {
            confirmation_token: "finish_token",
            user_name: "Test User",
            email: "finish@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
    end

    assert_redirected_to root_path

    user = User.find_by(name: "Test User")
    assert_not_nil user

    db_auth = User::DatabaseAuthentication.find_by(email: "finish@example.com")
    assert_not_nil db_auth
    assert_equal user, db_auth.user

    assert_nil User::Confirmation.find_by(email: "finish@example.com")
  end

  test "POST /user/database_authentications 無効なトークンでエラー" do
    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count", "User::Confirmation.count" ] do
      post user_database_authentications_path, params: {
        confirmation: {
          confirmation_token: "invalid_token",
          user_name: "Test User",
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :not_found
  end

  test "POST /user/database_authentications パスワード不一致でエラー" do
    User::Confirmation.create!(
      email: "mismatch@example.com",
      confirmation_token: "mismatch_token",
      confirmation_sent_at: 1.hour.ago,
      confirmed_at: 10.minutes.ago
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      assert_no_difference "User::Confirmation.count" do
        post user_database_authentications_path, params: {
          confirmation: {
            confirmation_token: "mismatch_token",
            user_name: "Test User",
            email: "mismatch@example.com",
            password: "password123",
            password_confirmation: "different_password"
          }
        }
      end
    end

    assert_response :unprocessable_entity
    assert_select "form", count: 1
  end

  test "POST /user/database_authentications パスワードの長さ不足でエラー" do
    User::Confirmation.create!(
      email: "short@example.com",
      confirmation_token: "short_token",
      confirmation_sent_at: 1.hour.ago,
      confirmed_at: 10.minutes.ago
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      post user_database_authentications_path, params: {
        confirmation: {
          confirmation_token: "short_token",
          user_name: "Test User",
          email: "short@example.com",
          password: "123",
          password_confirmation: "123"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "POST /user/database_authentications 必須項目不足でエラー(name)" do
    User::Confirmation.create!(
      email: "missing@example.com",
      confirmation_token: "missing_token",
      confirmation_sent_at: 1.hour.ago,
      confirmed_at: 10.minutes.ago
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      post user_database_authentications_path, params: {
        confirmation: {
          confirmation_token: "missing_token",
          user_name: "",
          email: "missing@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # emailはconfirmationから自動的に設定されるため、リクエストのemailパラメータは無視される
  # このテストは「リクエストで別のemailを送信しても確認済みのemailで登録される」で十分カバーされている

  test "POST /user/database_authentications 必須項目不足でエラー(password)" do
    User::Confirmation.create!(
      email: "missing@example.com",
      confirmation_token: "missing_token",
      confirmation_sent_at: 1.hour.ago,
      confirmed_at: 10.minutes.ago
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      post user_database_authentications_path, params: {
        confirmation: {
          confirmation_token: "missing_token",
          user_name: "user",
          email: "missing@example.com",
          password: "",
          password_confirmation: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "POST /user/database_authentications 未確認のトークンでの登録は失敗" do
    User::Confirmation.create!(
      unconfirmed_email: "unconfirmed@example.com",
      confirmation_token: "unconfirmed_token",
      confirmation_sent_at: 10.minutes.ago
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      post user_database_authentications_path, params: {
        confirmation: {
          confirmation_token: "unconfirmed_token",
          user_name: "Test User",
          email: "unconfirmed@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "POST /user/database_authentications リクエストで別のemailを送信しても確認済みのemailで登録される" do
    User::Confirmation.create!(
      email: "confirmed@example.com",
      confirmation_token: "test_token",
      confirmation_sent_at: 1.hour.ago,
      confirmed_at: 30.minutes.ago
    )

    assert_difference [ "User.count", "User::DatabaseAuthentication.count" ], 1 do
      assert_difference "User::Confirmation.count", -1 do
        post user_database_authentications_path, params: {
          confirmation: {
            confirmation_token: "test_token",
            user_name: "Test User",
            email: "malicious@example.com", # 悪意のあるユーザーが別のemailを送信
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
    end

    assert_redirected_to root_path

    # 確認済みのemailで登録されていることを確認
    db_auth = User::DatabaseAuthentication.find_by(email: "confirmed@example.com")
    assert_not_nil db_auth, "confirmed@example.comで登録されるべき"

    # 悪意のあるemailでは登録されていないことを確認
    malicious_db_auth = User::DatabaseAuthentication.find_by(email: "malicious@example.com")
    assert_nil malicious_db_auth, "malicious@example.comでは登録されないべき"
  end
end
