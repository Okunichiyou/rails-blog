require "test_helper"

class Ui::EmailFieldComponentTest < ViewComponent::TestCase
  def form_builder
    ActionView::Helpers::FormBuilder.new("user_database_authentication", User::DatabaseAuthentication.new, vc_test_controller.view_context, {})
  end

  test "基本的な email_field が生成されること" do
    render_inline(Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :medium))

    assert_selector("input[type='email'][name='user_database_authentication[email]'][id='user_database_authentication_email']")
  end

  test "size のクラスが設定されること" do
    render_inline(Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :large))

    assert_selector("input.text-field-component.large")
  end

  test "html_options が適用されること" do
    component = Ui::EmailFieldComponent.new(
      builder: form_builder,
      method: :email,
      size: :medium,
      html_options: { autofocus: true, autocomplete: "email", class: "custom-class" }
    )

    render_inline(component)

    # 基本的なinput要素があることを確認
    assert_selector("input[type='email']")
    # autofocusとautocomplete属性があることを確認
    assert_selector("input[autofocus][autocomplete='email']")
    # classがマージされていることを確認
    assert_selector("input.text-field-component.medium")
    # custom-classも含まれていることを確認
    assert_selector("input.custom-class")
  end

  test "不適切なsizeを適用したらエラーが出ること" do
    assert_raises(ArgumentError, "Invalid attribute value: 'invalid'. Must be one of full, large, medium, small.") do
      Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :invalid)
    end
  end

  test "variant: defaultが適用されること" do
    render_inline(Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :medium, variant: :default))

    assert_selector("input.text-field-component.medium.default")
  end

  test "variant: alertが適用されること" do
    render_inline(Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :medium, variant: :alert))

    assert_selector("input.text-field-component.medium.alert")
  end

  test "variantのデフォルト値はdefaultであること" do
    render_inline(Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :medium))

    assert_selector("input.text-field-component.medium.default")
  end

  test "不適切なvariantを適用したらエラーが出ること" do
    assert_raises(ArgumentError, "Invalid attribute value: 'invalid'. Must be one of default, alert.") do
      Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :medium, variant: :invalid)
    end
  end
end
