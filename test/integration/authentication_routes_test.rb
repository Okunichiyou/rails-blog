require "test_helper"

class AuthenticationRoutesTest < ActionDispatch::IntegrationTest
  test "GET /login should route to login page" do
    get "/login"
    assert_response :success
    assert_select "h1", "ログイン"
  end

  test "login_path should return /login" do
    assert_equal "/login", login_path
  end

  test "logout_path should return /logout" do
    assert_equal "/logout", logout_path
  end
end
