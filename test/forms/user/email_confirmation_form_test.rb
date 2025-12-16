require "test_helper"

class User::EmailConfirmationFormTest < ActiveSupport::TestCase
  test "有効なメールアドレスでcallが成功すること" do
    form = User::EmailConfirmationForm.new(email: "test@example.com")

    assert_difference "User::Confirmation.count", 1 do
      assert form.call
    end

    registration = User::Confirmation.find_by(unconfirmed_email: "test@example.com")
    assert_not_nil registration
  end

  test "メールアドレスが空の場合にバリデーションエラーになること" do
    form = User::EmailConfirmationForm.new(email: "")

    assert_not form.valid?
    assert_includes form.errors[:email], "を入力してください"
  end

  test "メールアドレスが無効な形式の場合にバリデーションエラーになること" do
    form = User::EmailConfirmationForm.new(email: "invalid-email")

    assert_not form.valid?
    assert_includes form.errors[:email], "は不正な値です"
  end

  test "既存のメールアドレスで再送信する場合" do
    User::Confirmation.create!(unconfirmed_email: "existing@example.com", confirmation_token: "token")

    form = User::EmailConfirmationForm.new(email: "existing@example.com")

    assert_no_difference "User::Confirmation.count" do
      assert form.call
    end
  end

  test "メールアドレスの前後の空白が削除されること" do
    form = User::EmailConfirmationForm.new(email: "  test@example.com  ")

    assert form.call

    registration = User::Confirmation.find_by(unconfirmed_email: "test@example.com")
    assert_not_nil registration
  end

  test "バリデーションエラーがある場合callがfalseを返すこと" do
    form = User::EmailConfirmationForm.new(email: "")

    assert_no_difference "User::Confirmation.count" do
      assert_not form.call
    end
  end
end
