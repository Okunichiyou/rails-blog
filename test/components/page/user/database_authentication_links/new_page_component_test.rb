require "test_helper"

class Page::User::DatabaseAuthenticationLinks::NewPageComponentTest < ViewComponent::TestCase
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
    render_inline(Page::User::DatabaseAuthenticationLinks::NewPageComponent.new(
      form: @form,
      create_database_authentication_link_path: "/user/database_authentications/link_create"
    ))

    assert_selector("div.flex.justify-center")
  end

  test "h2タグでリンクフォームのタイトルが表示されること" do
    render_inline(Page::User::DatabaseAuthenticationLinks::NewPageComponent.new(
      form: @form,
      create_database_authentication_link_path: "/user/database_authentications/link_create"
    ))

    assert_selector("h2", text: "メール認証をリンク")
  end

  test "DatabaseAuthenticationLinkFormComponentが表示されること" do
    render_inline(Page::User::DatabaseAuthenticationLinks::NewPageComponent.new(
      form: @form,
      create_database_authentication_link_path: "/user/database_authentications/link_create"
    ))

    # フォームの主要な要素が含まれていることを確認
    assert_selector("form[action='/user/database_authentications/link_create']")
    assert_selector("input[name='confirmation[password]']")
  end
end
