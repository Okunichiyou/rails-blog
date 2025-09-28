require "test_helper"

class UserRegistrationsNewViewTest < ActionDispatch::IntegrationTest
  test "NewPageComponentが描画されていること" do
    get new_registration_confirmation_path

    assert_response :success
    assert_select ".page-user-registrations-new-page-component"
  end
end
