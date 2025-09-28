require "test_helper"

class Page::User::Registrations::NewPageComponentTest < ViewComponent::TestCase
  test "確認メールの送信のタイトルが表示されること" do
    render_inline(Page::User::Registrations::NewPageComponent.new(form: User::EmailConfirmationForm.new, confirmation_path: "/users/confirmation", resource_name: :registration))

    assert_selector("h2", text: "確認メールの送信")
  end

  test "PanelComponentが使用されていること" do
    render_inline(Page::User::Registrations::NewPageComponent.new(form: User::EmailConfirmationForm.new, confirmation_path: "/users/confirmation", resource_name: :registration))

    assert_selector(".ui-panel-component")
  end

  test "EmailConfirmationFormComponentが呼び出されていること" do
    render_inline(Page::User::Registrations::NewPageComponent.new(form: User::EmailConfirmationForm.new, confirmation_path: "/users/confirmation", resource_name: :registration))

    assert_selector("form.email-confirmation-form")
  end

  test "正しいパラメータでEmailConfirmationFormComponentが初期化されること" do
    form = User::EmailConfirmationForm.new(email: "test@example.com")

    render_inline(Page::User::Registrations::NewPageComponent.new(form: form, confirmation_path: "/users/confirmation", resource_name: :registration))

    assert_selector("form[action='/users/confirmation']")
    assert_selector("input[name*='email']")
  end
end
