require "test_helper"

class User::DatabaseAuthenticationLinkFormTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "testuser")

    @valid_attributes = {
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "valid_token"
    }

    @confirmation = User::Confirmation.create!(
      email: "link@example.com",
      confirmation_token: "valid_token",
      confirmation_sent_at: 10.minutes.ago,
      confirmed_at: 5.minutes.ago
    )
  end

  test "正常な入力でDatabaseAuthenticationが保存される" do
    form = User::DatabaseAuthenticationLinkForm.new(current_user: @user, **@valid_attributes)

    assert_difference "User::DatabaseAuthentication.count", 1 do
      assert_difference "User::Confirmation.count", -1 do
        assert form.call
      end
    end

    # Userは新規作成されない
    assert_no_difference "User.count" do
      form.call
    end

    auth = User::DatabaseAuthentication.find_by(email: "link@example.com")
    assert_not_nil auth
    assert_equal @user, auth.user

    # User::Confirmationが削除されていることを確認
    assert_nil User::Confirmation.find_by(confirmation_token: "valid_token")
  end

  test "Passwordが不正な場合、DatabaseAuthenticationの保存に失敗する" do
    form = User::DatabaseAuthenticationLinkForm.new(
      current_user: @user,
      password: "123", # 短すぎる
      password_confirmation: "123",
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User::DatabaseAuthentication.count", "User::Confirmation.count" ] do
      assert_not form.call
    end

    assert form.errors[:password].any?
  end

  test "Password confirmationが不一致の場合、DatabaseAuthenticationの保存に失敗する" do
    form = User::DatabaseAuthenticationLinkForm.new(
      current_user: @user,
      password: "password123",
      password_confirmation: "different", # 不一致
      confirmation_token: "valid_token"
    )

    assert_no_difference [ "User::DatabaseAuthentication.count", "User::Confirmation.count" ] do
      assert_not form.call
    end

    assert form.errors[:password_confirmation].any?
  end

  # =====================================
  # メールアドレス重複チェック
  # =====================================

  test "database_authenticationで既に使用されているemailの場合、emailにエラーが格納される" do
    existing_user = User.create!(name: "Existing User")
    User::DatabaseAuthentication.create!(
      user: existing_user,
      email: "link@example.com",
      password: "password123"
    )

    form = User::DatabaseAuthenticationLinkForm.new(current_user: @user, **@valid_attributes)

    assert_no_difference "User::DatabaseAuthentication.count" do
      assert_not form.call
    end

    assert form.errors[:email].any?, "emailのエラーが格納されていない"
  end

  # =====================================
  # トークン検証
  # =====================================

  test "無効なトークンの場合、confirmation_tokenにエラーが格納される" do
    form = User::DatabaseAuthenticationLinkForm.new(
      current_user: @user,
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "invalid_token"
    )

    assert_not form.valid?
    assert form.errors[:base].any?, "confirmation_tokenのエラーが格納されていない"
  end

  test "未確認のトークンの場合、confirmation_tokenにエラーが格納される" do
    User::Confirmation.create!(
      unconfirmed_email: "unconfirmed@example.com",
      confirmation_token: "unconfirmed_token",
      confirmation_sent_at: 10.minutes.ago
    )

    form = User::DatabaseAuthenticationLinkForm.new(
      current_user: @user,
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "unconfirmed_token"
    )

    assert_not form.valid?
    assert form.errors[:base].any?, "confirmation_tokenのエラーが格納されていない"
  end

  # =====================================
  # current_user検証
  # =====================================

  test "current_userがnilの場合、baseにエラーが格納される" do
    form = User::DatabaseAuthenticationLinkForm.new(
      current_user: nil,
      password: "password123",
      password_confirmation: "password123",
      confirmation_token: "valid_token"
    )

    assert_not form.valid?
    assert form.errors[:base].any?, "baseのエラーが格納されていない"
  end

  test "current_userが既にdatabase_authenticationを持っている場合、baseにエラーが格納される" do
    User::DatabaseAuthentication.create!(
      user: @user,
      email: "existing@example.com",
      password: "password123"
    )

    form = User::DatabaseAuthenticationLinkForm.new(current_user: @user, **@valid_attributes)

    assert_not form.valid?
    assert form.errors[:base].any?, "baseのエラーが格納されていない"
  end

  # =====================================
  # フォーム属性のゲッター
  # =====================================

  test "emailはconfirmation_resourceから取得される" do
    form = User::DatabaseAuthenticationLinkForm.new(current_user: @user, **@valid_attributes)

    assert_equal "link@example.com", form.email
  end

  test "user_nameはcurrent_userから取得される" do
    form = User::DatabaseAuthenticationLinkForm.new(current_user: @user, **@valid_attributes)

    assert_equal "testuser", form.user_name
  end

  test "model_nameはConfirmationを返す" do
    form = User::DatabaseAuthenticationLinkForm.new(current_user: @user, **@valid_attributes)

    assert_equal "Confirmation", form.model_name.name
  end
end
