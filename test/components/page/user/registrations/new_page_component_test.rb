require "test_helper"

class Page::User::Registrations::NewPageComponentTest < ViewComponent::TestCase
  test "確認メールの送信のタイトルが表示されること" do
    registration = User::Registration.new

    render_inline(Page::User::Registrations::NewPageComponent.new(resource: registration, resource_name: :user_registration, confirmation_path: "/users/confirmation"))

    assert_selector("h2", text: "確認メールの送信")
  end

  test "PanelComponentが使用されていること" do
    registration = User::Registration.new

    render_inline(Page::User::Registrations::NewPageComponent.new(resource: registration, resource_name: :user_registration, confirmation_path: "/users/confirmation"))

    assert_selector(".ui-panel-component")
  end

  test "EmailConfirmationFormComponentが呼び出されていること" do
    registration = User::Registration.new

    render_inline(Page::User::Registrations::NewPageComponent.new(resource: registration, resource_name: :user_registration, confirmation_path: "/users/confirmation"))

    assert_selector("form.email-confirmation-form")
  end

  test "正しいパラメータでEmailConfirmationFormComponentが初期化されること" do
    registration = User::Registration.new(email: "test@example.com")

    render_inline(Page::User::Registrations::NewPageComponent.new(resource: registration, resource_name: :user_registration, confirmation_path: "/users/confirmation"))

    assert_selector("form[action='/users/confirmation']")
    assert_selector("input[value='test@example.com']")
  end
end
