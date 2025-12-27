require "test_helper"

class ApplicationFormTest < ActiveSupport::TestCase
  test "model_name.nameはクラス名からFormサフィックスを除いたものになる" do
    form = User::EmailConfirmationForm.new

    assert_equal "User::EmailConfirmation", form.model_name.name
  end

  test "model_name.param_keyはフォームのパラメータ名として使える形式になる" do
    form = User::EmailConfirmationForm.new

    assert_equal "user_email_confirmation", form.model_name.param_key
  end
end
