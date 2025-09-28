require "test_helper"

class Domain::User::EmailConfirmationFormComponentTest < ViewComponent::TestCase
  test "flashがある場合、flashを表示していること" do
    form = User::EmailConfirmationForm.new
    flash_mock = { notice: "確認メールを送信しました" }

    component = Domain::User::EmailConfirmationFormComponent.new(form: form, confirmation_path: "/users/confirmation", resource_name: :registration)
    component.define_singleton_method(:flash) { flash_mock }

    render_inline(component)

    assert_selector(".ui-flash-component.notice", text: "確認メールを送信しました")
  end

  test "email-confirmation-formの要素があること" do
    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: User::EmailConfirmationForm.new, confirmation_path: "/users/confirmation", resource_name: :registration))

    assert_selector("form.email-confirmation-form")
  end

  test "emailのラベルとinput要素があること" do
    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: User::EmailConfirmationForm.new, confirmation_path: "/users/confirmation", resource_name: :registration))

    assert_selector("label[for='registration_email']", text: "Email")
    assert_selector("input[type=email][name='registration[email]'][id='registration_email']")
  end

  test "submitボタンがあること" do
    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: User::EmailConfirmationForm.new, confirmation_path: "/users/confirmation", resource_name: :registration))

    assert_selector("button[type=submit]", text: "送信")
  end

  test "未確認のメールアドレスが設定されたフォームが表示されること" do
    form = User::EmailConfirmationForm.new(email: "new@example.com")

    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: form, confirmation_path: "/users/confirmation", resource_name: :registration))

    assert_selector("input[name*='email']")
    assert_selector("label", text: "Email")
  end

  test "確認済みのメールアドレスが設定されたフォームが表示されること" do
    form = User::EmailConfirmationForm.new(email: "confirmed@example.com")

    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: form, confirmation_path: "/users/confirmation", resource_name: :registration))

    assert_selector("input[name*='email']")
    assert_selector("label", text: "Email")
  end
end
