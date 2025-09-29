require "test_helper"

class UserRegistrationsSentViewTest < ActionDispatch::IntegrationTest
  test "SentPageComponentが描画されていること" do
    get registration_confirmation_sent_path

    assert_response :success
    assert_select ".page-user-registrations-sent-page-component"
  end
end
