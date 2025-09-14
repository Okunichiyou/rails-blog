require "test_helper"

class Ui::PasswordFieldComponentTest < ViewComponent::TestCase
  def form_builder
    ActionView::Helpers::FormBuilder.new("user_database_authentication", User::DatabaseAuthentication.new, vc_test_controller.view_context, {})
  end

  test "基本的な password_field が生成されること" do
    render_inline(Ui::PasswordFieldComponent.new(builder: form_builder, method: :password, size: :medium))

    assert_selector("input[type='password'][name='user_database_authentication[password]'][id='user_database_authentication_password']")
  end

  test "size のクラスが設定されること" do
    render_inline(Ui::PasswordFieldComponent.new(builder: form_builder, method: :password, size: :large))

    assert_selector("input.text-field-component.large")
  end

  test "html_options が適用されること" do
    component = Ui::PasswordFieldComponent.new(
      builder: form_builder,
      method: :password,
      size: :medium,
      html_options: { autocomplete: "current-password", class: "custom-class" }
    )

    render_inline(component)

    # 基本的なinput要素があることを確認
    assert_selector("input[type='password']")
    # autocomplete属性があることを確認
    assert_selector("input[autocomplete='current-password']")
    # classがマージされていることを確認
    assert_selector("input.text-field-component.medium")
    # custom-classも含まれていることを確認
    assert_selector("input.custom-class")
  end

  test "不適切なsizeを適用したらエラーが出ること" do
    assert_raises(ArgumentError, "Invalid attribute value: 'invalid'. Must be one of full, large, medium, small.") do
      Ui::PasswordFieldComponent.new(builder: form_builder, method: :password, size: :invalid)
    end
  end
end
