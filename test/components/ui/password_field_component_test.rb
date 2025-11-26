require "test_helper"

class Ui::PasswordFieldComponentTest < ViewComponent::TestCase
  # @rbs () -> ActionView::Helpers::FormBuilder
  def form_builder
    ActionView::Helpers::FormBuilder.new("user_database_authentication", User::DatabaseAuthentication.new, vc_test_controller.view_context, {})
  end

  test "基本的な password_field が生成されること" do
    render_inline(Ui::PasswordFieldComponent.new(builder: form_builder, method: :password, size: :medium))

    assert_selector("input[type='password'][name='user_database_authentication[password]'][id='user_database_authentication_password']")
  end

  test "html_options が適用されること" do
    component = Ui::PasswordFieldComponent.new(
      builder: form_builder,
      method: :password,
      size: :medium,
      autocomplete: "current-password",
      class: "custom-class"
    )

    render_inline(component)

    # 基本的なinput要素があることを確認
    assert_selector("input[type='password']")
    # autocomplete属性があることを確認
    assert_selector("input[autocomplete='current-password']")
    # custom-classも含まれていることを確認
    assert_selector("input.custom-class")
  end

  test "不適切なsizeを適用したらエラーが出ること" do
    assert_raises(ArgumentError, "Invalid attribute value: 'invalid'. Must be one of full, large, medium, small.") do
      Ui::PasswordFieldComponent.new(builder: form_builder, method: :password, size: :invalid)
    end
  end

  test "不適切なvariantを適用したらエラーが出ること" do
    assert_raises(ArgumentError, "Invalid attribute value: 'invalid'. Must be one of default, alert.") do
      Ui::PasswordFieldComponent.new(builder: form_builder, method: :password, size: :medium, variant: :invalid)
    end
  end
end
