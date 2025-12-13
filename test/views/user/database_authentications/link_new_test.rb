require "test_helper"

class UserDatabaseAuthenticationsLinkNewViewTest < ActionView::TestCase
  # @rbs () -> bool
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
    @form.valid?
  end

  test "PanelComponentが表示されること" do
    render template: "user/database_authentications/link_new"

    assert_select("div.flex.justify-center")
  end

  test "h2タグでリンクフォームのタイトルが表示されること" do
    render template: "user/database_authentications/link_new"

    assert_select("h2", text: "メール認証をリンク")
  end

  test "DatabaseAuthenticationLinkFormComponentが表示されること" do
    render template: "user/database_authentications/link_new"

    # フォームの主要な要素が含まれていることを確認
    assert_select("form[action='/user/database_authentications/link_create']")
    assert_select("input[name='confirmation[password]']")
  end
end
