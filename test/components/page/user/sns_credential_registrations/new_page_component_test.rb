require "test_helper"

class Page::User::SnsCredentialRegistrations::NewPageComponentTest < ViewComponent::TestCase
  def setup
    @pending = user_pending_sns_credentials(:one)
    @form = User::SnsCredentialRegistrationForm.new(
      token: @pending.token,
      user_name: @pending.name
    )
    @form.valid?
  end

  test "PanelComponentが表示されること" do
    render_inline(Page::User::SnsCredentialRegistrations::NewPageComponent.new(
      form: @form,
      create_sns_credential_registration_path: "/user/sns_credential_registrations"
    ))

    assert_selector("div.flex.justify-center")
  end

  test "h2タグで登録フォームのタイトルが表示されること" do
    render_inline(Page::User::SnsCredentialRegistrations::NewPageComponent.new(
      form: @form,
      create_sns_credential_registration_path: "/user/sns_credential_registrations"
    ))

    assert_selector("h2", text: "登録フォーム")
  end

  test "SnsCredentialRegistrationFormComponentが表示されること" do
    render_inline(Page::User::SnsCredentialRegistrations::NewPageComponent.new(
      form: @form,
      create_sns_credential_registration_path: "/user/sns_credential_registrations"
    ))

    # フォームの主要な要素が含まれていることを確認
    assert_selector("form[action='/user/sns_credential_registrations']")
    assert_selector("input[name='sns_credential_registration[user_name]']")
  end
end
