require "test_helper"

class Domain::User::LoginFormComponentTest < ViewComponent::TestCase
  test "flashがある場合、flashを表示していること" do
    database_auth = User::DatabaseAuthentication.new
    flash_mock = { notice: "ログインしてください" }

    component = Domain::User::LoginFormComponent.new(resource: database_auth, resource_name: :user_database_authentication)
    component.define_singleton_method(:flash) { flash_mock }

    render_inline(component)

    assert_selector("div", text: "ログインしてください")
  end

  test "database-authentication-formの要素があること" do
    database_auth = User::DatabaseAuthentication.new

    render_inline(Domain::User::LoginFormComponent.new(resource: database_auth, resource_name: :user_database_authentication))

    assert_selector("form.database-authentication-form")
  end

  test "emailのラベルとinput要素があること" do
    database_auth = User::DatabaseAuthentication.new

    render_inline(Domain::User::LoginFormComponent.new(resource: database_auth, resource_name: :user_database_authentication))

    assert_selector("label[for='user_database_authentication_email']", text: "Email")
    assert_selector("input[type=email][name='user_database_authentication[email]'][id='user_database_authentication_email']")
  end

  test "passwordのラベルとinput要素があること" do
    database_auth = User::DatabaseAuthentication.new

    render_inline(Domain::User::LoginFormComponent.new(resource: database_auth, resource_name: :user_database_authentication))

    assert_selector("label[for='user_database_authentication_password']", text: "Password")
    assert_selector("input[type=password][name='user_database_authentication[password]'][id='user_database_authentication_password']")
  end

  test "submitボタンがあること" do
    database_auth = User::DatabaseAuthentication.new

    render_inline(Domain::User::LoginFormComponent.new(resource: database_auth, resource_name: :user_database_authentication))

    assert_selector("button[type=submit]")
  end
end
