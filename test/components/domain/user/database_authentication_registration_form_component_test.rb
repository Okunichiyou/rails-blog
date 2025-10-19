require "test_helper"

class Domain::User::DatabaseAuthenticationRegistrationFormComponentTest < ViewComponent::TestCase
  test "registration formの要素があること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      create_database_authentication_path: "/user/database_authentications"
    ))

    assert_selector("form[action='/user/database_authentications'][method=post]")
  end

  test "nameのラベルとinput要素があること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      create_database_authentication_path: "/user/database_authentications"
    ))

    assert_selector("label[for='confirmation_user_name']", text: "User name")
    assert_selector("input[type=text][name='confirmation[user_name]'][id='confirmation_user_name']")
  end

  test "emailのラベルとテキスト表示があること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      create_database_authentication_path: "/user/database_authentications"
    ))

    assert_selector("label[for='confirmation_email']", text: "Email")
    assert_selector("p", text: "test@example.com")
  end

  test "passwordのラベルとinput要素があること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      create_database_authentication_path: "/user/database_authentications"
    ))

    assert_selector("label[for='confirmation_password']", text: "Password")
    assert_selector("input[type=password][name='confirmation[password]'][id='confirmation_password']")
  end

  test "password_confirmationのラベルとinput要素があること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      create_database_authentication_path: "/user/database_authentications"
    ))

    assert_selector("label[for='confirmation_password_confirmation']", text: "Password confirmation")
    assert_selector("input[type=password][name='confirmation[password_confirmation]'][id='confirmation_password_confirmation']")
  end

  test "confirmation_tokenのhidden fieldがあること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      create_database_authentication_path: "/user/database_authentications"
    ))

    assert_selector("input[type=hidden][name='confirmation[confirmation_token]']", visible: false)
    assert_selector("input[value='token123']", visible: false)
  end

  test "submitボタンがあること" do
    form = User::DatabaseAuthenticationRegistrationForm.new(
      email: "test@example.com",
      confirmation_token: "token123"
    )

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: form,
      create_database_authentication_path: "/user/database_authentications"
    ))

    assert_selector("button[type=submit]", text: "Submit")
  end
end
