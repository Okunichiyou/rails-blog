require "test_helper"

class Ui::EmailFieldComponentTest < ViewComponent::TestCase
  # @rbs () -> ActionView::Helpers::FormBuilder
  def form_builder
    ActionView::Helpers::FormBuilder.new("user_database_authentication", User::DatabaseAuthentication.new, vc_test_controller.view_context, {})
  end

  test "基本的な email_field が生成されること" do
    render_inline(Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :medium))

    assert_selector("input[type='email'][name='user_database_authentication[email]'][id='user_database_authentication_email']")
  end

  test "html_options が適用されること" do
    component = Ui::EmailFieldComponent.new(
      builder: form_builder,
      method: :email,
      size: :medium,
      autofocus: true,
      autocomplete: "email",
      class: "custom-class"
    )

    render_inline(component)

    # 基本的なinput要素があることを確認
    assert_selector("input[type='email']")
    # autofocusとautocomplete属性があることを確認
    assert_selector("input[autofocus][autocomplete='email']")
    # custom-classも含まれていることを確認
    assert_selector("input.custom-class")
  end

  test "size: :full で w-full クラスが適用されること" do
    render_inline(Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :full))

    assert_selector("input.w-full")
  end

  test "size: :large で w-[20rem] クラスが適用されること" do
    render_inline(Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :large))

    assert_selector('input.w-\[20rem\]')
  end

  test "size: :small で w-[10rem] クラスが適用されること" do
    render_inline(Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :small))

    assert_selector('input.w-\[10rem\]')
  end

  test "variant: :alert で border-alert クラスが適用されること" do
    render_inline(Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :medium, variant: :alert))

    assert_selector("input.border-alert")
  end

  test "不適切なsizeを適用したらエラーが出ること" do
    assert_raises(ArgumentError, "Invalid attribute value: 'invalid'. Must be one of full, large, medium, small.") do
      Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :invalid)
    end
  end

  test "不適切なvariantを適用したらエラーが出ること" do
    assert_raises(ArgumentError, "Invalid attribute value: 'invalid'. Must be one of default, alert.") do
      Ui::EmailFieldComponent.new(builder: form_builder, method: :email, size: :medium, variant: :invalid)
    end
  end
end
