require "test_helper"

class UserValidatorTest < ActiveSupport::TestCase
  # valid_email? のテスト（完全にカバー）
  test "valid_email? returns false for nil" do
    assert_equal false, UserValidator.valid_email?(nil)
  end

  test "valid_email? returns false for empty string" do
    assert_equal false, UserValidator.valid_email?("")
  end

  test "valid_email? returns true for valid email" do
    assert_equal true, UserValidator.valid_email?("test@example.com")
  end

  test "valid_email? returns false for invalid email" do
    assert_equal false, UserValidator.valid_email?("invalid")
  end

  # valid_password? のテスト（部分的にカバー）
  test "valid_password? returns false for nil" do
    assert_equal false, UserValidator.valid_password?(nil)
  end

  test "valid_password? returns false for short password" do
    assert_equal false, UserValidator.valid_password?("Pass1")
  end

  test "valid_password? returns true for valid password" do
    assert_equal true, UserValidator.valid_password?("Password123")
  end

  # valid_username? のテスト（一部のみカバー）
  test "valid_username? returns false for nil" do
    assert_equal false, UserValidator.valid_username?(nil)
  end

  test "valid_username? returns true for valid username" do
    assert_equal true, UserValidator.valid_username?("user_123")
  end

  # valid_age? はテストしない（カバレッジなし）
end
