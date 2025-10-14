require "test_helper"

class Domain::User::DatabaseAuthenticationRegistrationFormComponentTest < ViewComponent::TestCase
  test "registration formの要素があること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      finish_user_registration_path: "/users/finish_registration"
    ))

    assert_selector("form[action='/users/finish_registration'][method=post]")
  end

  test "nameのラベルとinput要素があること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      finish_user_registration_path: "/users/finish_registration"
    ))

    assert_selector("label[for='registration_user_name']", text: "User name")
    assert_selector("input[type=text][name='registration[user_name]'][id='registration_user_name']")
  end

  test "emailのラベルとテキスト表示があること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      finish_user_registration_path: "/users/finish_registration"
    ))

    assert_selector("label[for='registration_email']", text: "Email")
    assert_selector("p", text: "test@example.com")
  end

  test "passwordのラベルとinput要素があること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      finish_user_registration_path: "/users/finish_registration"
    ))

    assert_selector("label[for='registration_password']", text: "Password")
    assert_selector("input[type=password][name='registration[password]'][id='registration_password']")
  end

  test "password_confirmationのラベルとinput要素があること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      finish_user_registration_path: "/users/finish_registration"
    ))

    assert_selector("label[for='registration_password_confirmation']", text: "Password confirmation")
    assert_selector("input[type=password][name='registration[password_confirmation]'][id='registration_password_confirmation']")
  end

  test "confirmation_tokenのhidden fieldがあること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      finish_user_registration_path: "/users/finish_registration"
    ))

    assert_selector("input[type=hidden][name='registration[confirmation_token]']", visible: false)
    assert_selector("input[value='token123']", visible: false)
  end

  test "submitボタンがあること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      finish_user_registration_path: "/users/finish_registration"
    ))

    assert_selector("button[type=submit]", text: "Submit")
  end
end
