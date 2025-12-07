require "test_helper"

class User::AccountSettingsControllerTest < ActionDispatch::IntegrationTest
  test "ログイン済みユーザーはアカウント設定画面を表示できる" do
    # ログイン
    post login_path, params: {
      database_authentication: {
        email: "db_auth@example.com",
        password: "password123"
      }
    }

    get user_account_settings_path

    assert_response :success
  end

  test "未ログインユーザーはログイン画面にリダイレクトされる" do
    get user_account_settings_path

    assert_redirected_to login_path
    assert_equal "ログインしてください", flash[:alert]
  end
end
