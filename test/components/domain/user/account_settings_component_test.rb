require "test_helper"

class Domain::User::AccountSettingsComponentTest < ViewComponent::TestCase
  test "Googleアカウントが連携されていない場合、連携ボタンが表示される" do
    user = User.create!(name: "Test User")

    render_inline(Domain::User::AccountSettingsComponent.new(user: user))

    assert_selector("button[type=submit]", text: "Googleアカウントで連携する")
    assert_no_selector("span.text-notice-inline", text: "連携済み")
  end

  test "Googleアカウントが連携されている場合、連携済みメッセージが表示される" do
    user = User.create!(name: "Test User")
    User::SnsCredential.create!(
      user: user,
      provider: "google_oauth2",
      uid: "123456789",
      email: "test@example.com"
    )

    render_inline(Domain::User::AccountSettingsComponent.new(user: user))

    assert_selector("span.text-notice-inline", text: "連携済み")
    assert_no_selector("button[type=submit]", text: "Googleアカウントで連携する")
  end

  test "連携アカウントのヘッダーが表示される" do
    user = User.create!(name: "Test User")

    render_inline(Domain::User::AccountSettingsComponent.new(user: user))

    assert_selector("h2", text: "連携アカウント")
  end

  test "Google連携の項目が表示される" do
    user = User.create!(name: "Test User")

    render_inline(Domain::User::AccountSettingsComponent.new(user: user))

    assert_selector("dt", text: "Google連携")
  end
end
