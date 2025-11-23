require "test_helper"

class Ui::TextFieldComponentTest < ViewComponent::TestCase
  def form_builder
    ActionView::Helpers::FormBuilder.new("registration", User::DatabaseAuthenticationRegistrationForm.new, vc_test_controller.view_context, {})
  end

  test "基本的な text_field が生成されること" do
    render_inline(Ui::TextFieldComponent.new(builder: form_builder, method: :user_name, size: :medium))

    assert_selector("input[type='text'][name='registration[user_name]'][id='registration_user_name']")
  end

  test "html_options が適用されること" do
    component = Ui::TextFieldComponent.new(
      builder: form_builder,
      method: :user_name,
      size: :medium,
      placeholder: "Enter your name",
      class: "custom-class"
    )

    render_inline(component)

    # 基本的なinput要素があることを確認
    assert_selector("input[type='text']")
    # placeholder属性があることを確認
    assert_selector("input[placeholder='Enter your name']")
    # custom-classも含まれていることを確認
    assert_selector("input.custom-class")
  end

  test "不適切なsizeを適用したらエラーが出ること" do
    assert_raises(ArgumentError, "Invalid attribute value: 'invalid'. Must be one of full, large, medium, small.") do
      Ui::TextFieldComponent.new(builder: form_builder, method: :user_name, size: :invalid)
    end
  end

  test "不適切なvariantを適用したらエラーが出ること" do
    assert_raises(ArgumentError, "Invalid attribute value: 'invalid'. Must be one of default, alert.") do
      Ui::TextFieldComponent.new(builder: form_builder, method: :user_name, size: :medium, variant: :invalid)
    end
  end
end
