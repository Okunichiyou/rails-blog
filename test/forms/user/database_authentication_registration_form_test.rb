require "test_helper"

class User::DatabaseAuthenticationRegistrationFormTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      user_name: "testuser",
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "valid_token"
    }

    @confirmation = User::Confirmation.create!(
      email: "test@example.com",
      confirmation_token: "valid_token",
      confirmation_sent_at: 10.minutes.ago,
      confirmed_at: 5.minutes.ago
    )
  end

  test "正常な入力でUserとDatabaseAuthenticationのUserとDatabaseAuthenticationの両方が保存される" do
    form = User::DatabaseAuthenticationRegistrationForm.new(@valid_attributes)

    assert_difference [ "User.count", "User::DatabaseAuthentication.count" ], 1 do
      assert_difference "User::Confirmation.count", -1 do
        assert form.save
      end
    end

    user = User.find_by(name: "testuser")
    assert_not_nil user

    auth = User::DatabaseAuthentication.find_by(email: "test@example.com")
    assert_not_nil auth
    assert_equal user, auth.user

    # User::Confirmationが削除されていることを確認
    assert_nil User::Confirmation.find_by(confirmation_token: "valid_token")
  end

  test "User名が不正でもDatabaseAuthenticationのバリデーションも実行され、UserとDatabaseAuthenticationのエラーが両方とも格納される" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "", # User: 空白エラー
      password: "", # DatabaseAuthentication: 空白エラー
      password_confirmation: "",
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      assert_not form.save
    end

    # 両方のバリデーションエラーが格納されていることを確認
    assert form.errors[:user_name].any?, "User nameのエラーが格納されていない"
    assert form.errors[:password].any?, "Passwordのエラーが格納されていない"
  end

  test "DatabaseAuthenticationが不正でもUserのバリデーションも実行され、両方のエラーが格納される" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "", # User: 空白エラー
      password: "password123",
      password_confirmation: "invalid_password", # DatabaseAuthentication: パスワード不一致エラー
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      assert_not form.save
    end

    # 両方のバリデーションエラーが格納されていることを確認
    assert form.errors[:user_name].any?, "User nameのエラーが格納されていない"
    assert form.errors[:password_confirmation].any?, "Passwordのエラーが格納されていない"
  end

  test "User名が不正な場合、UserもDatabaseAuthenticationも保存に失敗する" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "", # 不正
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count", "User::Confirmation.count" ] do
      assert_not form.save
    end

    assert form.errors[:user_name].any?
  end

  test "Passwordが不正な場合、UserもDatabaseAuthenticationも保存に失敗する" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "testuser",
      password: "123", # 短すぎる
      password_confirmation: "123",
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count", "User::Confirmation.count" ] do
      assert_not form.save
    end

    assert form.errors[:password].any?
  end

  test "Password confirmationが不一致の場合、UserもDatabaseAuthenticationも保存に失敗する" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "testuser",
      password: "password123",
      password_confirmation: "different", # 不一致
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count", "User::Confirmation.count" ] do
      assert_not form.save
    end

    assert form.errors[:password_confirmation].any?
  end

  test "User名が255文字を超える場合、UserもDatabaseAuthenticationも保存に失敗する" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "a" * 256, # 長すぎる
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count", "User::Confirmation.count" ] do
      assert_not form.save
    end

    assert form.errors[:user_name].any?
  end

  test "User名が重複している場合、UserもDatabaseAuthenticationも保存に失敗する" do
    User.create!(name: "existinguser")

    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "existinguser", # 重複
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count", "User::Confirmation.count" ] do
      assert_not form.save
    end

    assert form.errors[:user_name].any?
  end

  test "複数のバリデーションエラーが同時に発生した場合、全てのエラーが格納される" do
    User.create!(name: "existinguser")

    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "existinguser", # User: 重複エラー
      password: "123", # DatabaseAuthentication: 長さエラー
      password_confirmation: "456", # DatabaseAuthentication: 不一致エラー
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      assert_not form.save
    end

    # 全てのエラーが格納されていることを確認
    assert form.errors[:user_name].any?, "User nameのエラーが格納されていない"
    assert form.errors[:password].any?, "Passwordのエラーが格納されていない"
    assert form.errors[:password_confirmation].any?, "Password confirmationのエラーが格納されていない"
  end

  # =====================================
  # メールアドレス重複チェック
  # =====================================

  test "database_authenticationで既に使用されているemailの場合、emailにエラーが格納される" do
    existing_user = User.create!(name: "Existing User")
    User::DatabaseAuthentication.create!(
      user: existing_user,
      email: "test@example.com",
      password: "password123"
    )

    form = User::DatabaseAuthenticationRegistrationForm.new(@valid_attributes)

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      assert_not form.save
    end

    assert form.errors[:email].any?, "emailのエラーが格納されていない"
  end

  test "sns_credentialで既に使用されているemailの場合、emailにエラーが格納される" do
    existing_user = User.create!(name: "Existing User")
    User::SnsCredential.create!(
      user: existing_user,
      provider: "google",
      uid: "12345",
      email: "test@example.com"
    )

    form = User::DatabaseAuthenticationRegistrationForm.new(@valid_attributes)

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      assert_not form.save
    end

    assert form.errors[:email].any?, "emailのエラーが格納されていない"
  end

  # =====================================
  # トークン検証
  # =====================================

  test "無効なトークンの場合、confirmation_tokenにエラーが格納される" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "testuser",
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "invalid_token"
    )

    assert_not form.valid?
    assert form.errors[:confirmation_token].any?, "confirmation_tokenのエラーが格納されていない"
  end

  test "未確認のトークンの場合、confirmation_tokenにエラーが格納される" do
    User::Confirmation.create!(
      unconfirmed_email: "unconfirmed@example.com",
      confirmation_token: "unconfirmed_token",
      confirmation_sent_at: 10.minutes.ago
    )

    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "testuser",
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "unconfirmed_token"
    )

    assert_not form.valid?
    assert form.errors[:confirmation_token].any?, "confirmation_tokenのエラーが格納されていない"
  end
end
