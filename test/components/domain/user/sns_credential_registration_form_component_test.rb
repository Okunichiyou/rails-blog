require "test_helper"

class Domain::User::SnsCredentialRegistrationFormComponentTest < ViewComponent::TestCase
  # @rbs () -> bool
  def setup
    @pending = user_pending_sns_credentials(:one)
    @form = User::SnsCredentialRegistrationForm.new(
      token: @pending.token,
      user_name: @pending.name
    )
    # valid?を呼ぶことで@pending_credentialが設定される
    @form.valid?
  end

  test "registration formの要素があること" do
    render_inline(Domain::User::SnsCredentialRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("form[action='/user/sns_credential_registrations'][method=post]")
  end

  test "user_nameのラベルとinput要素があること" do
    render_inline(Domain::User::SnsCredentialRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("label[for='user_sns_credential_registration_user_name']", text: "ユーザー名")
    assert_selector("input[type=text][name='user_sns_credential_registration[user_name]'][id='user_sns_credential_registration_user_name']")
  end

  test "user_nameの初期値が設定されていること" do
    render_inline(Domain::User::SnsCredentialRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("input[value='#{@pending.name}']")
  end

  test "emailのラベルとテキスト表示があること" do
    render_inline(Domain::User::SnsCredentialRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("label[for='user_sns_credential_registration_email']", text: "Email")
    assert_selector("p", text: @pending.email)
  end

  test "tokenのhidden fieldがあること" do
    render_inline(Domain::User::SnsCredentialRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("input[type=hidden][name='user_sns_credential_registration[token]']", visible: false)
    assert_selector("input[value='#{@pending.token}']", visible: false)
  end

  test "submitボタンがあること" do
    render_inline(Domain::User::SnsCredentialRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("button[type=submit]", text: "登録")
  end

  test "tokenにエラーがある場合、FlashComponentでエラーメッセージが表示されること" do
    @form.errors.add(:token, :not_found, message: "が見つかりません")

    render_inline(Domain::User::SnsCredentialRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("div", text: "Tokenが見つかりません")
  end

  test "baseエラーがある場合、FlashComponentでエラーメッセージが表示されること" do
    @form.errors.add(:base, "既に同じメールアドレスでアカウントが連携されています。このメールアドレスでSNS認証を利用するには、一度ログインしてからアカウント連携を行ってください。")

    render_inline(Domain::User::SnsCredentialRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("div", text: "既に同じメールアドレスでアカウントが連携されています。このメールアドレスでSNS認証を利用するには、一度ログインしてからアカウント連携を行ってください。")
  end

  test "user_nameにエラーがある場合、エラーメッセージが表示されること" do
    @form.errors.add(:user_name, :blank, message: "を入力してください")

    render_inline(Domain::User::SnsCredentialRegistrationFormComponent.new(
      form: @form
    ))

    assert_selector("div", text: "User nameを入力してください")
  end
end
