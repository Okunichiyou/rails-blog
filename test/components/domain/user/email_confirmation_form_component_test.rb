require "test_helper"

class Domain::User::EmailConfirmationFormComponentTest < ViewComponent::TestCase
  test "flashがある場合、flashを表示していること" do
    registration = User::Registration.new
    flash_mock = { notice: "確認メールを送信しました" }

    component = Domain::User::EmailConfirmationFormComponent.new(resource: registration, resource_name: :user_registration, confirmation_path: "/users/confirmation")
    component.define_singleton_method(:flash) { flash_mock }

    render_inline(component)

    assert_selector(".ui-flash-component.notice", text: "確認メールを送信しました")
  end

  test "email-confirmation-formの要素があること" do
    registration = User::Registration.new

    render_inline(Domain::User::EmailConfirmationFormComponent.new(resource: registration, resource_name: :user_registration, confirmation_path: "/users/confirmation"))

    assert_selector("form.email-confirmation-form")
  end

  test "emailのラベルとinput要素があること" do
    registration = User::Registration.new

    render_inline(Domain::User::EmailConfirmationFormComponent.new(resource: registration, resource_name: :user_registration, confirmation_path: "/users/confirmation"))

    assert_selector("label[for='user_registration_email']", text: "Email")
    assert_selector("input[type=email][name='user_registration[email]'][id='user_registration_email']")
  end

  test "submitボタンがあること" do
    registration = User::Registration.new

    render_inline(Domain::User::EmailConfirmationFormComponent.new(resource: registration, resource_name: :user_registration, confirmation_path: "/users/confirmation"))

    assert_selector("button[type=submit]", text: "送信")
  end

  test "pending_reconfirmation時に未確認のメールアドレスが表示されること" do
    registration = User::Registration.new(email: "old@example.com", unconfirmed_email: "new@example.com")
    registration.define_singleton_method(:pending_reconfirmation?) { true }

    render_inline(Domain::User::EmailConfirmationFormComponent.new(resource: registration, resource_name: :user_registration, confirmation_path: "/users/confirmation"))

    assert_selector("input[value='new@example.com']")
  end

  test "pending_reconfirmationでない時に確認済みのメールアドレスが表示されること" do
    registration = User::Registration.new(email: "confirmed@example.com")
    registration.define_singleton_method(:pending_reconfirmation?) { false }

    render_inline(Domain::User::EmailConfirmationFormComponent.new(resource: registration, resource_name: :user_registration, confirmation_path: "/users/confirmation"))

    assert_selector("input[value='confirmed@example.com']")
  end
end
