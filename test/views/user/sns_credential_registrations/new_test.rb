require "test_helper"

class UserSnsCredentialRegistrationsNewViewTest < ActionView::TestCase
  # @rbs () -> bool
  def setup
    @pending = user_pending_sns_credentials(:one)
    @form = User::SnsCredentialRegistrationForm.new(
      token: @pending.token,
      user_name: @pending.name
    )
    @form.valid?
  end

  test "PanelComponentが表示されること" do
    render template: "user/sns_credential_registrations/new"

    assert_select("div.flex.justify-center")
  end

  test "h2タグで登録フォームのタイトルが表示されること" do
    render template: "user/sns_credential_registrations/new"

    assert_select("h2", text: "登録フォーム")
  end

  test "SnsCredentialRegistrationFormComponentが表示されること" do
    render template: "user/sns_credential_registrations/new"

    # フォームの主要な要素が含まれていることを確認
    assert_select("form[action='/user/sns_credential_registrations']")
    assert_select("input[name='sns_credential_registration[user_name]']")
  end
end
