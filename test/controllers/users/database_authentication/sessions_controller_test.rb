require "test_helper"

class Users::DatabaseAuthentication::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User")
    @user_database_authentication = User::DatabaseAuthentication.create!(
      user: @user,
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  # =====================================
  # newアクション（ログイン画面表示）
  # =====================================

  test "GET /database_authentication/login ログイン画面表示" do
    get login_path

    assert_response :success
  end

  # =====================================
  # createアクション（ログイン処理）
  # =====================================

  test "POST /database_authentication/login 正しい認証情報でログイン成功" do
    post login_path, params: {
      database_authentication: {
        email: "test@example.com",
        password: "password123"
      }
    }

    assert_redirected_to root_path
    # Deviseのセッションキーを確認
    assert_not_nil session["warden.user.user.key"]
    assert_not_nil session["warden.user.database_authentication.key"]
  end

  test "POST /database_authentication/login 存在しないメールアドレスでログイン失敗" do
    post login_path, params: {
      database_authentication: {
        email: "nonexistent@example.com",
        password: "password123"
      }
    }

    assert_response :unprocessable_content
    assert_nil session["warden.user.user.key"]
    assert_nil session["warden.user.database_authentication.key"]
  end

  test "POST /database_authentication/login 間違ったパスワードでログイン失敗" do
    post login_path, params: {
      database_authentication: {
        email: "test@example.com",
        password: "wrongpassword"
      }
    }

    assert_response :unprocessable_content
    assert_nil session["warden.user.user.key"]
    assert_nil session["warden.user.database_authentication.key"]
  end

  # =====================================
  # destroyアクション（ログアウト処理）
  # =====================================

  test "DELETE /database_authentication/logout ログアウト成功" do
    # ログイン状態を作成
    post login_path, params: {
      database_authentication: {
        email: "test@example.com",
        password: "password123"
      }
    }

    # ログアウト実行
    delete logout_path

    assert_redirected_to root_path
    assert_nil session["warden.user.user.key"]
    assert_nil session["warden.user.database_authentication.key"]
  end

  test "DELETE /database_authentication/logout 未ログイン状態でログアウト" do
    delete logout_path

    assert_redirected_to root_path
    assert_nil session["warden.user.user.key"]
    assert_nil session["warden.user.database_authentication.key"]
  end
end
