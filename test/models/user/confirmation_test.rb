require "test_helper"

class User::ConfirmationTest < ActiveSupport::TestCase
  # =====================================
  # Deviseモジュールテスト
  # =====================================

  test "confirmableモジュールが含まれている" do
    assert User::Confirmation.devise_modules.include?(:confirmable)
  end

  # =====================================
  # バリデーションテスト
  # =====================================

  test "emailなしでもインスタンス作成できる" do
    confirmation = User::Confirmation.new

    assert_kind_of User::Confirmation, confirmation
  end

  test "emailが設定できる" do
    confirmation = User::Confirmation.new
    confirmation.email = "test@example.com"

    assert_equal "test@example.com", confirmation.email
  end

  test "emailの前後空白がトリミングされる" do
    confirmation = User::Confirmation.new
    confirmation.email = "  trimmed@example.com  "
    confirmation.valid?

    assert_equal "trimmed@example.com", confirmation.email
  end

  test "unconfirmed_emailの前後空白がトリミングされる" do
    confirmation = User::Confirmation.new
    confirmation.unconfirmed_email = "  trimmed@example.com  "
    confirmation.valid?

    assert_equal "trimmed@example.com", confirmation.unconfirmed_email
  end

  test "unconfirmed_emailが無効な形式の場合にバリデーションエラーになる" do
    confirmation = User::Confirmation.new(unconfirmed_email: "invalid-email")

    assert_not confirmation.valid?
    assert_includes confirmation.errors[:unconfirmed_email], "は不正な値です"
  end

  test "unconfirmed_emailが有効な形式の場合にバリデーションが通る" do
    confirmation = User::Confirmation.new(unconfirmed_email: "valid@example.com")

    confirmation.valid?

    assert_empty confirmation.errors[:unconfirmed_email]
  end

  test "unconfirmed_emailが空の場合はフォーマットバリデーションをスキップする" do
    confirmation = User::Confirmation.new(unconfirmed_email: "")

    confirmation.valid?

    assert_not_includes confirmation.errors[:unconfirmed_email], "は不正な値です"
  end

  test "confirmed_atが設定できる" do
    confirmation = User::Confirmation.new
    time = Time.current
    confirmation.confirmed_at = time

    assert_equal time.to_i, confirmation.confirmed_at.to_i
  end

  test "confirmation_tokenが設定できる" do
    confirmation = User::Confirmation.new
    token = "test_token"
    confirmation.confirmation_token = token

    assert_equal token, confirmation.confirmation_token
  end

  # =====================================
  # 確認メール有効期限テスト
  # =====================================

  test "Deviseの確認メール有効期限が30分に設定されている" do
    assert_equal 30.minutes, Devise.confirm_within
  end

  # =====================================
  # データベース制約
  # =====================================

  test "データベースレベルでconfirmation_tokenのNOT NULL制約が働く" do
    assert_raises ActiveRecord::NotNullViolation do
      User::Confirmation.connection.execute(
        "INSERT INTO user_confirmations (email, confirmation_token, created_at, updated_at) VALUES ('null_token@example.com', NULL, datetime('now'), datetime('now'))"
      )
    end
  end
end
