require "test_helper"

class Users::SnsCredentialRegistrationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @pending = user_pending_sns_credentials(:one)
  end

  # フォームのparam_keyを使用してパラメータを構築
  # これにより、model_nameの変更がテストで検知される
  def form_params(attributes)
    param_key = User::SnsCredentialRegistrationForm.new(token: "dummy").model_name.param_key.to_sym
    { param_key => attributes }
  end

  test "GET new: 有効なトークンでフォームを表示" do
    get new_users_sns_credential_registration_path(token: @pending.token)

    assert_response :success
    assert_select "h2", "登録フォーム"
    assert_select "input[name='user_sns_credential_registration[user_name]']"
    assert_select "input[type='hidden'][name='user_sns_credential_registration[token]']"
  end

  test "GET new: Googleから取得したユーザー名が初期値として設定されている" do
    get new_users_sns_credential_registration_path(token: @pending.token)

    assert_response :success
    assert_select "input[name='user_sns_credential_registration[user_name]'][value=?]", @pending.name
  end

  test "GET new: メールアドレスが表示される" do
    get new_users_sns_credential_registration_path(token: @pending.token)

    assert_response :success
    assert_select "p", @pending.email
  end

  test "GET new: 無効なトークンの場合はエラー画面" do
    get new_users_sns_credential_registration_path(token: "invalid_token")

    assert_response :unprocessable_content
  end

  test "GET new: 期限切れトークンの場合はエラー画面" do
    expired = user_pending_sns_credentials(:expired)
    get new_users_sns_credential_registration_path(token: expired.token)

    assert_response :unprocessable_content
  end

  test "POST create: 有効なパラメータでユーザーを作成してログイン" do
    assert_difference "User.count", 1 do
      assert_difference "User::SnsCredential.count", 1 do
        post users_sns_credential_registrations_path, params: form_params(
          token: @pending.token,
          user_name: "Custom User Name"
        )
      end
    end

    assert_redirected_to root_path
    assert_equal "アカウントの登録が完了しました", flash[:notice]

    created_user = User.find_by(name: "Custom User Name")
    assert_not_nil created_user

    # SnsCredentialが正しく作成されていることを確認
    sns_credential = User::SnsCredential.find_by(user: created_user)
    assert_not_nil sns_credential
    assert_equal @pending.provider, sns_credential.provider
    assert_equal @pending.uid, sns_credential.uid
    assert_equal @pending.email, sns_credential.email
  end

  test "POST create: PendingSnsCredentialが削除される" do
    assert_difference "User::PendingSnsCredential.count", -1 do
      post users_sns_credential_registrations_path, params: form_params(
        token: @pending.token,
        user_name: "Custom User Name"
      )
    end

    assert_nil User::PendingSnsCredential.find_by(token: @pending.token)
  end

  test "POST create: user_nameが空の場合はエラー" do
    assert_no_difference [ "User.count", "User::SnsCredential.count" ] do
      post users_sns_credential_registrations_path, params: form_params(
        token: @pending.token,
        user_name: ""
      )
    end

    assert_response :unprocessable_content
    # エラーメッセージが表示されていることを確認
    assert_match /can&#39;t be blank|を入力してください/, response.body
  end

  test "POST create: 無効なトークンの場合はエラー" do
    assert_no_difference [ "User.count", "User::SnsCredential.count" ] do
      post users_sns_credential_registrations_path, params: form_params(
        token: "invalid_token",
        user_name: "Test User"
      )
    end

    assert_response :unprocessable_content
  end

  test "POST create: 既存のユーザー名の場合はエラー" do
    existing_user = users(:one)

    assert_no_difference [ "User.count", "User::SnsCredential.count" ] do
      post users_sns_credential_registrations_path, params: form_params(
        token: @pending.token,
        user_name: existing_user.name
      )
    end

    assert_response :unprocessable_content
    # エラーメッセージが表示されていることを確認
    assert_match /has already been taken|はすでに存在します/, response.body
  end

  test "POST create: メールアドレスが既に使用されている場合はエラー" do
    user = users(:one)
    User::DatabaseAuthentication.create!(
      user: user,
      email: @pending.email,
      password: "password123",
      password_confirmation: "password123"
    )

    assert_no_difference [ "User.count", "User::SnsCredential.count" ] do
      post users_sns_credential_registrations_path, params: form_params(
        token: @pending.token,
        user_name: "Test User"
      )
    end

    assert_response :unprocessable_content
    assert_match "既に同じメールアドレスでアカウントが連携されています。このメールアドレスでSNS認証を利用するには、一度ログインしてからアカウント連携を行ってください。", response.body
  end
end
