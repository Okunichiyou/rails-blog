require "test_helper"

class Domain::User::DatabaseAuthenticationLinkFormComponentTest < ViewComponent::TestCase
  # @rbs () -> User::DatabaseAuthenticationLinkForm
  def setup
    @user = User.create!(name: "testuser")
    confirmation = User::Confirmation.create!(
      email: "link@example.com",
      confirmation_token: "link_token_123",
      confirmed_at: Time.current
    )
    @form = User::DatabaseAuthenticationLinkForm.new(
      current_user: @user,
      confirmation_token: confirmation.confirmation_token
    )
  end

  test "link formの要素があること" do
    render_inline(Domain::User::DatabaseAuthenticationLinkFormComponent.new(
      form: @form
    ))

    assert_selector("form[action='/users/database_authentications/link_create'][method=post]")
  end

  test "user_nameのラベルとテキスト表示があること" do
    render_inline(Domain::User::DatabaseAuthenticationLinkFormComponent.new(
      form: @form
    ))

    assert_selector("label[for='user_database_authentication_link_user_name']", text: "ユーザー名")
    assert_selector("p", text: "testuser")
  end

  test "emailのラベルとテキスト表示があること" do
    render_inline(Domain::User::DatabaseAuthenticationLinkFormComponent.new(
      form: @form
    ))

    assert_selector("label[for='user_database_authentication_link_email']", text: "Email")
    assert_selector("p", text: "link@example.com")
  end

  test "passwordのラベルとinput要素があること" do
    render_inline(Domain::User::DatabaseAuthenticationLinkFormComponent.new(
      form: @form
    ))

    assert_selector("label[for='user_database_authentication_link_password']", text: "Password")
    assert_selector("input[type=password][name='user_database_authentication_link[password]'][id='user_database_authentication_link_password']")
  end

  test "password_confirmationのラベルとinput要素があること" do
    render_inline(Domain::User::DatabaseAuthenticationLinkFormComponent.new(
      form: @form
    ))

    assert_selector("label[for='user_database_authentication_link_password_confirmation']", text: "Password confirmation")
    assert_selector("input[type=password][name='user_database_authentication_link[password_confirmation]'][id='user_database_authentication_link_password_confirmation']")
  end

  test "confirmation_tokenのhidden fieldがあること" do
    render_inline(Domain::User::DatabaseAuthenticationLinkFormComponent.new(
      form: @form
    ))

    assert_selector("input[type=hidden][name='user_database_authentication_link[confirmation_token]']", visible: false)
    assert_selector("input[value='link_token_123']", visible: false)
  end

  test "submitボタンがあること" do
    render_inline(Domain::User::DatabaseAuthenticationLinkFormComponent.new(
      form: @form
    ))

    assert_selector("button[type=submit]", text: "リンク")
  end

  test "confirmation_tokenにエラーがある場合、FlashComponentでエラーメッセージが表示されること" do
    @form.errors.add(:base, :token_not_found, message: "認証トークンが見つかりません")

    render_inline(Domain::User::DatabaseAuthenticationLinkFormComponent.new(
      form: @form
    ))

    assert_selector("div", text: "認証トークンが見つかりません")
  end
end
