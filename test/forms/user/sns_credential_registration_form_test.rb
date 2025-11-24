require "test_helper"

class User::SnsCredentialRegistrationFormTest < ActiveSupport::TestCase
  def setup
    @pending = user_pending_sns_credentials(:one)
  end

  test "有効なパラメータでバリデーションが通る" do
    form = User::SnsCredentialRegistrationForm.new(
      token: @pending.token,
      user_name: "Test User"
    )

    assert form.valid?
  end

  test "user_nameが空の場合はバリデーションエラー" do
    form = User::SnsCredentialRegistrationForm.new(
      token: @pending.token,
      user_name: ""
    )

    assert_not form.valid?
    assert_includes form.errors[:user_name], "can't be blank"
  end

  test "tokenが空の場合はバリデーションエラー" do
    form = User::SnsCredentialRegistrationForm.new(
      token: "",
      user_name: "Test User"
    )

    assert_not form.valid?
    assert_includes form.errors[:token], "can't be blank"
  end

  test "tokenが存在しない場合はバリデーションエラー" do
    form = User::SnsCredentialRegistrationForm.new(
      token: "invalid_token",
      user_name: "Test User"
    )

    assert_not form.valid?
    assert_includes form.errors[:token], "が見つかりません"
  end

  test "tokenが期限切れの場合はバリデーションエラー" do
    expired = user_pending_sns_credentials(:expired)
    form = User::SnsCredentialRegistrationForm.new(
      token: expired.token,
      user_name: "Test User"
    )

    assert_not form.valid?
    assert_includes form.errors[:token], "の有効期限が切れています"
  end

  test "user_nameが既に使用されている場合はバリデーションエラー" do
    existing_user = users(:one)
    form = User::SnsCredentialRegistrationForm.new(
      token: @pending.token,
      user_name: existing_user.name
    )

    assert_not form.valid?
    assert_includes form.errors[:user_name], "has already been taken"
  end

  test "token_validation_only コンテキストではuser_nameをバリデーションしない" do
    form = User::SnsCredentialRegistrationForm.new(
      token: @pending.token,
      user_name: ""
    )

    assert form.valid?(:token_validation_only)
  end

  test "callでユーザーとSNS認証情報を作成できる" do
    form = User::SnsCredentialRegistrationForm.new(
      token: @pending.token,
      user_name: "New User Name"
    )

    assert_difference "User.count", 1 do
      assert_difference "User::SnsCredential.count", 1 do
        assert form.call
      end
    end

    assert_not_nil form.user
    assert_equal "New User Name", form.user.name
  end

  test "callでPendingSnsCredentialが削除される" do
    form = User::SnsCredentialRegistrationForm.new(
      token: @pending.token,
      user_name: "New User Name"
    )

    assert_difference "User::PendingSnsCredential.count", -1 do
      form.call
    end

    assert_nil User::PendingSnsCredential.find_by(token: @pending.token)
  end

  test "email メソッドでPendingSnsCredentialのメールアドレスを取得できる" do
    form = User::SnsCredentialRegistrationForm.new(
      token: @pending.token,
      user_name: "Test User"
    )

    # valid?を呼ぶことで@pending_credentialが設定される
    form.valid?
    assert_equal @pending.email, form.email
  end

  test "provider メソッドでPendingSnsCredentialのプロバイダーを取得できる" do
    form = User::SnsCredentialRegistrationForm.new(
      token: @pending.token,
      user_name: "Test User"
    )

    # valid?を呼ぶことで@pending_credentialが設定される
    form.valid?
    assert_equal @pending.provider, form.provider
  end

  test "無効なフォームでcallを呼ぶとfalseを返す" do
    form = User::SnsCredentialRegistrationForm.new(
      token: @pending.token,
      user_name: ""
    )

    assert_not form.call
  end

  test "メールアドレスが既に使用されている場合callが失敗する" do
    user = users(:one)
    User::DatabaseAuthentication.create!(
      user: user,
      email: @pending.email,
      password: "password123",
      password_confirmation: "password123"
    )

    form = User::SnsCredentialRegistrationForm.new(
      token: @pending.token,
      user_name: "Test User"
    )

    assert_not form.call
    assert_includes form.errors[:base], "既に同じメールアドレスでアカウントが連携されています"
  end
end
