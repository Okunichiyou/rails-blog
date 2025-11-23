require "test_helper"

class GoogleAuthTest < ActiveSupport::TestCase
  test "initializeでclient_idとclient_secretを設定する" do
    google_auth = GoogleAuth.new

    assert_equal "test_id", google_auth.client_id
    assert_equal "test_secret", google_auth.client_secret
  end
end
