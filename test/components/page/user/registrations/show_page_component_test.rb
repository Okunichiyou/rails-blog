require "test_helper"

class Page::User::Registrations::ShowPageComponentTest < ViewComponent::TestCase
  test "Registration Formのタイトルが表示されること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Page::User::Registrations::ShowPageComponent.new(
      form: form,
      finish_user_registration_path: "/users/finish_registration"
    ))

    assert_selector("h2", text: "Registration Form")
  end

  test "PanelComponentが使用されていること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Page::User::Registrations::ShowPageComponent.new(
      form: form,
      finish_user_registration_path: "/users/finish_registration"
    ))

    assert_selector(".ui-panel-component")
  end

  test "DatabaseAuthenticationRegistrationFormComponentが呼び出されていること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Page::User::Registrations::ShowPageComponent.new(
      form: form,
      finish_user_registration_path: "/users/finish_registration"
    ))

    assert_selector("form[action='/users/finish_registration']")
  end

  test "正しいパラメータでDatabaseAuthenticationRegistrationFormComponentが初期化されること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Page::User::Registrations::ShowPageComponent.new(
      form: form,
      finish_user_registration_path: "/users/finish_registration"
    ))

    assert_selector("input[name='registration[email]'][value='test@example.com']")
    assert_selector("input[name='registration[confirmation_token]'][value='token123']", visible: false)
  end
end
