require "test_helper"

class User::DatabaseAuthenticationRegistrationFormTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      user_name: "testuser",
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "valid_token"
    }

    @registration = User::Registration.create!(
      unconfirmed_email: "test@example.com",
      confirmation_token: "valid_token",
      confirmation_sent_at: 10.minutes.ago,
      confirmed_at: 5.minutes.ago
    )
  end

  test "正常な入力でUserとDatabaseAuthenticationのUserとDatabaseAuthenticationの両方が保存される" do
    form = User::DatabaseAuthenticationRegistrationForm.new(@valid_attributes)

    assert_difference [ "User.count", "User::DatabaseAuthentication.count" ], 1 do
      assert_difference "User::Registration.count", -1 do
        assert form.call
      end
    end

    user = User.find_by(name: "testuser")
    assert_not_nil user

    auth = User::DatabaseAuthentication.find_by(email: "test@example.com")
    assert_not_nil auth
    assert_equal user, auth.user

    # User::Registrationが削除されていることを確認
    assert_nil User::Registration.find_by(confirmation_token: "valid_token")
  end

  test "User名が不正でもDatabaseAuthenticationのバリデーションも実行され、UserとDatabaseAuthenticationのエラーが両方とも格納される" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "", # User: 空白エラー
      email: "test@example.com",
      password: "", # DatabaseAuthentication: 空白エラー
      password_confirmation: "",
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      assert_not form.call
    end

    # 両方のバリデーションエラーが格納されていることを確認
    assert form.errors[:user_name].any?, "User nameのエラーが格納されていない"
    assert form.errors[:password].any?, "Passwordのエラーが格納されていない"
  end

  test "DatabaseAuthenticationが不正でもUserのバリデーションも実行され、両方のエラーが格納される" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "", # User: 空白エラー
      email: "invalid-email", # DatabaseAuthentication: 形式エラー
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      assert_not form.call
    end

    # 両方のバリデーションエラーが格納されていることを確認
    assert form.errors[:user_name].any?, "User nameのエラーが格納されていない"
    assert form.errors[:email].any?, "Emailのエラーが格納されていない"
  end

  test "User名が不正な場合、UserもDatabaseAuthenticationも保存に失敗する" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "", # 不正
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count", "User::Registration.count" ] do
      assert_not form.call
    end

    assert form.errors[:user_name].any?
  end

  test "Emailが不正な場合、UserもDatabaseAuthenticationも保存に失敗する" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "testuser",
      email: "invalid-email", # 不正
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count", "User::Registration.count" ] do
      assert_not form.call
    end

    assert form.errors[:email].any?
  end

  test "Passwordが不正な場合、UserもDatabaseAuthenticationも保存に失敗する" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "testuser",
      email: "test@example.com",
      password: "123", # 短すぎる
      password_confirmation: "123",
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count", "User::Registration.count" ] do
      assert_not form.call
    end

    assert form.errors[:password].any?
  end

  test "Password confirmationが不一致の場合、UserもDatabaseAuthenticationも保存に失敗する" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "testuser",
      email: "test@example.com",
      password: "password123",
      password_confirmation: "different", # 不一致
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count", "User::Registration.count" ] do
      assert_not form.call
    end

    assert form.errors[:password_confirmation].any?
  end

  test "User名が255文字を超える場合、UserもDatabaseAuthenticationも保存に失敗する" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "a" * 256, # 長すぎる
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count", "User::Registration.count" ] do
      assert_not form.call
    end

    assert form.errors[:user_name].any?
  end

  test "User名が重複している場合、UserもDatabaseAuthenticationも保存に失敗する" do
    User.create!(name: "existinguser")

    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "existinguser", # 重複
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count", "User::Registration.count" ] do
      assert_not form.call
    end

    assert form.errors[:user_name].any?
  end

  test "複数のバリデーションエラーが同時に発生した場合、全てのエラーが格納される" do
    User.create!(name: "existinguser")

    form = User::DatabaseAuthenticationRegistrationForm.new(
      user_name: "existinguser", # User: 重複エラー
      email: "invalid", # DatabaseAuthentication: 形式エラー
      password: "123", # DatabaseAuthentication: 長さエラー
      password_confirmation: "456", # DatabaseAuthentication: 不一致エラー
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User.count", "User::DatabaseAuthentication.count" ] do
      assert_not form.call
    end

    # 全てのエラーが格納されていることを確認
    assert form.errors[:user_name].any?, "User nameのエラーが格納されていない"
    assert form.errors[:email].any?, "Emailのエラーが格納されていない"
    assert form.errors[:password].any?, "Passwordのエラーが格納されていない"
    assert form.errors[:password_confirmation].any?, "Password confirmationのエラーが格納されていない"
  end
end
