require "test_helper"

class Domain::User::DatabaseAuthenticationRegistrationFormComponentTest < ViewComponent::TestCase
  # @rbs () -> User::DatabaseAuthenticationRegistrationForm
  def setup
    confirmation = User::Confirmation.create!(
      email: "test@example.com",
      confirmation_token: "test_token_123",
      confirmed_at: Time.current
    )
    @form = User::DatabaseAuthenticationRegistrationForm.new(confirmation_token: confirmation.confirmation_token)
  end

  test "registration formの要素があること" do
    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("form[action='/user/database_authentications'][method=post]")
  end

  test "nameのラベルとinput要素があること" do
    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("label[for='user_database_authentication_registration_user_name']", text: "User name")
    assert_selector("input[type=text][name='user_database_authentication_registration[user_name]'][id='user_database_authentication_registration_user_name']")
  end

  test "emailのラベルとテキスト表示があること" do
    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("label[for='user_database_authentication_registration_email']", text: "Email")
    assert_selector("p", text: "test@example.com")
  end

  test "passwordのラベルとinput要素があること" do
    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("label[for='user_database_authentication_registration_password']", text: "Password")
    assert_selector("input[type=password][name='user_database_authentication_registration[password]'][id='user_database_authentication_registration_password']")
  end

  test "password_confirmationのラベルとinput要素があること" do
    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("label[for='user_database_authentication_registration_password_confirmation']", text: "Password confirmation")
    assert_selector("input[type=password][name='user_database_authentication_registration[password_confirmation]'][id='user_database_authentication_registration_password_confirmation']")
  end

  test "confirmation_tokenのhidden fieldがあること" do
    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("input[type=hidden][name='user_database_authentication_registration[confirmation_token]']", visible: false)
    assert_selector("input[value='test_token_123']", visible: false)
  end

  test "submitボタンがあること" do
    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("button[type=submit]", text: "登録")
  end

  test "confirmation_tokenにエラーがある場合、FlashComponentでエラーメッセージが表示されること" do
    @form.errors.add(:confirmation_token, :not_found, message: "が見つかりません")

    render_inline(Domain::User::DatabaseAuthenticationRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("div", text: "Confirmation tokenが見つかりません")
  end
end
