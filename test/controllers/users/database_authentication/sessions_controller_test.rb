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

  # =====================================
  # アカウントロック機能（Lockable）
  # =====================================

  test "POST /database_authentication/login 5回連続ログイン失敗でアカウントがロックされる" do
    5.times do
      post login_path, params: {
        database_authentication: {
          email: "test@example.com",
          password: "wrongpassword"
        }
      }
    end

    @user_database_authentication.reload
    assert @user_database_authentication.access_locked?
  end

  test "POST /database_authentication/login ロック中は正しいパスワードでもログインできない" do
    @user_database_authentication.lock_access!

    post login_path, params: {
      database_authentication: {
        email: "test@example.com",
        password: "password123"
      }
    }

    assert_response :unprocessable_content
    assert_nil session["warden.user.user.key"]
  end

  test "POST /database_authentication/login ロックから1時間経過後はログインできる" do
    @user_database_authentication.lock_access!

    travel 1.hour + 1.second do
      post login_path, params: {
        database_authentication: {
          email: "test@example.com",
          password: "password123"
        }
      }

      assert_redirected_to root_path
      assert_not_nil session["warden.user.user.key"]
    end
  end

  test "POST /database_authentication/login ログイン成功でfailed_attemptsがリセットされる" do
    # 4回失敗
    4.times do
      post login_path, params: {
        database_authentication: {
          email: "test@example.com",
          password: "wrongpassword"
        }
      }
    end

    @user_database_authentication.reload
    assert_equal 4, @user_database_authentication.failed_attempts

    # ログイン成功
    post login_path, params: {
      database_authentication: {
        email: "test@example.com",
        password: "password123"
      }
    }

    @user_database_authentication.reload
    assert_equal 0, @user_database_authentication.failed_attempts
  end

  test "POST /database_authentication/login 4回失敗してもアカウントはロックされない" do
    4.times do
      post login_path, params: {
        database_authentication: {
          email: "test@example.com",
          password: "wrongpassword"
        }
      }
    end

    @user_database_authentication.reload
    assert_not @user_database_authentication.access_locked?
    assert_equal 4, @user_database_authentication.failed_attempts
  end
end
