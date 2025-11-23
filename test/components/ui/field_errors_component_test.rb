require "test_helper"

class Ui::FieldErrorsComponentTest < ViewComponent::TestCase
  test "エラーメッセージがない場合は何も表示されないこと" do
    render_inline(Ui::FieldErrorsComponent.new(error_messages: []))

    assert_no_selector("ul")
  end

  test "単一のエラーメッセージが表示されること" do
    render_inline(Ui::FieldErrorsComponent.new(error_messages: [ "Email can't be blank" ]))

    assert_selector("ul li", text: "Email can't be blank")
  end

  test "複数のエラーメッセージがリストで表示されること" do
    error_messages = [ "Email can't be blank", "Email is invalid" ]
    render_inline(Ui::FieldErrorsComponent.new(error_messages: error_messages))

    assert_selector("ul li", count: 2)
    assert_selector("ul li", text: "Email can't be blank")
    assert_selector("ul li", text: "Email is invalid")
  end
end
