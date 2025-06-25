require "test_helper"

class User::RegistrationTest < ActiveSupport::TestCase
  # =====================================
  # Deviseモジュールテスト
  # =====================================

  test "confirmableモジュールが含まれている" do
    assert User::Registration.devise_modules.include?(:confirmable)
  end

  # =====================================
  # バリデーションテスト
  # =====================================

  test "emailなしでもインスタンス作成できる" do
    registration = User::Registration.new

    assert_kind_of User::Registration, registration
  end

  test "emailが設定できる" do
    registration = User::Registration.new
    registration.email = "test@example.com"

    assert_equal "test@example.com", registration.email
  end

  test "emailの前後空白がトリミングされる" do
    registration = User::Registration.new
    registration.email = "  trimmed@example.com  "
    registration.valid?

    assert_equal "trimmed@example.com", registration.email
  end

  test "confirmed_atが設定できる" do
    registration = User::Registration.new
    time = Time.current
    registration.confirmed_at = time

    assert_equal time.to_i, registration.confirmed_at.to_i
  end

  test "confirmation_tokenが設定できる" do
    registration = User::Registration.new
    token = "test_token"
    registration.confirmation_token = token

    assert_equal token, registration.confirmation_token
  end

  # =====================================
  # データベース制約
  # =====================================

  test "データベースレベルでconfirmation_tokenのNOT NULL制約が働く" do
    assert_raises ActiveRecord::NotNullViolation do
      User::Registration.connection.execute(
        "INSERT INTO user_registrations (email, confirmation_token, created_at, updated_at) VALUES ('null_token@example.com', NULL, datetime('now'), datetime('now'))"
      )
    end
  end
end
