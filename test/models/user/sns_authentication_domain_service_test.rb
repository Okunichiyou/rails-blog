require "test_helper"

class User::SnsAuthenticationDomainServiceTest < ActiveSupport::TestCase
  # @rbs () -> User::OmniauthData
  def setup
    @omniauth_data = User::OmniauthData.new(
      provider: "google",
      uid: "123456789",
      name: "Test User",
      email: "test@example.com"
    )
  end

  test "authenticate_or_create returns success with existing sns_credential" do
    user = users(:one)
    User::SnsCredential.create!(
      user: user,
      provider: @omniauth_data.provider,
      uid: @omniauth_data.uid,
      email: @omniauth_data.email
    )

    result = User::SnsAuthenticationDomainService.authenticate_or_create(@omniauth_data)

    assert result.success?
    assert_equal user, result.user
    assert_nil result.error
  end

  test "authenticate_or_create returns pending_registration for new user" do
    assert_difference "User::PendingSnsCredential.count", 1 do
      assert_no_difference [ "User.count", "User::SnsCredential.count" ] do
        result = User::SnsAuthenticationDomainService.authenticate_or_create(@omniauth_data)

        assert result.pending_registration?
        assert_nil result.user
        assert_not_nil result.token
        assert_nil result.error

        # PendingSnsCredentialが作成されていることを確認
        pending = User::PendingSnsCredential.find_by(token: result.token)
        assert_not_nil pending
      end
    end
  end

  test "authenticate_or_create fails when email is already used in DatabaseAuthentication" do
    user = users(:one)
    User::DatabaseAuthentication.create!(
      user: user,
      email: @omniauth_data.email,
      password: "password123",
      password_confirmation: "password123"
    )

    result = User::SnsAuthenticationDomainService.authenticate_or_create(@omniauth_data)

    assert result.failure?
    assert_nil result.user
    assert_equal :email_already_used, result.error
    assert_equal "既に同じメールアドレスでアカウントが連携されています。このメールアドレスでSNS認証を利用するには、一度ログインしてからアカウント連携を行ってください。", result.message
  end

  test "authenticate_or_create fails when email is already used in SnsCredential" do
    user = users(:one)
    User::SnsCredential.create!(
      user: user,
      provider: "github",
      uid: "different_uid",
      email: @omniauth_data.email
    )

    result = User::SnsAuthenticationDomainService.authenticate_or_create(@omniauth_data)

    assert result.failure?
    assert_nil result.user
    assert_equal :email_already_used, result.error
    assert_equal "既に同じメールアドレスでアカウントが連携されています。このメールアドレスでSNS認証を利用するには、一度ログインしてからアカウント連携を行ってください。", result.message
  end

  test "create_from_pending creates user and sns_credential from pending token" do
    pending = User::PendingSnsCredential.create_from_omniauth!(@omniauth_data)

    assert_difference "User.count", 1 do
      assert_difference "User::SnsCredential.count", 1 do
        assert_difference "User::PendingSnsCredential.count", -1 do
          result = User::SnsAuthenticationDomainService.create_from_pending(pending.token, "Custom Name")

          assert result.success?
          assert_not_nil result.user
          assert_equal "Custom Name", result.user.name
          assert_nil result.error

          created_credential = User::SnsCredential.find_by(uid: @omniauth_data.uid)
          assert_equal result.user, created_credential.user
          assert_equal @omniauth_data.provider, created_credential.provider
          assert_equal @omniauth_data.uid, created_credential.uid
          assert_equal @omniauth_data.email, created_credential.email

          # PendingSnsCredentialが削除されていることを確認
          assert_nil User::PendingSnsCredential.find_by(token: pending.token)
        end
      end
    end
  end

  test "create_from_pending fails when token is invalid" do
    result = User::SnsAuthenticationDomainService.create_from_pending("invalid_token", "Test Name")

    assert result.failure?
    assert_nil result.user
    assert_equal :token_not_found_or_expired, result.error
    assert_equal "登録トークンが見つからないか、有効期限が切れています", result.message
  end

  test "create_from_pending fails when token is expired" do
    pending = user_pending_sns_credentials(:expired)

    result = User::SnsAuthenticationDomainService.create_from_pending(pending.token, "Test Name")

    assert result.failure?
    assert_nil result.user
    assert_equal :token_not_found_or_expired, result.error
  end

  test "create_from_pending fails when email is already used" do
    user = users(:one)
    User::DatabaseAuthentication.create!(
      user: user,
      email: @omniauth_data.email,
      password: "password123",
      password_confirmation: "password123"
    )

    pending = User::PendingSnsCredential.create_from_omniauth!(@omniauth_data)

    result = User::SnsAuthenticationDomainService.create_from_pending(pending.token, "Test Name")

    assert result.failure?
    assert_nil result.user
    assert_equal :email_already_used, result.error
    assert_equal "既に同じメールアドレスでアカウントが連携されています。このメールアドレスでSNS認証を利用するには、一度ログインしてからアカウント連携を行ってください。", result.message
  end

  test "authenticate_or_create fails when omniauth_data is invalid" do
    invalid_data = User::OmniauthData.new(
      provider: "google",
      uid: "123456789",
      name: nil,
      email: nil
    )

    result = User::SnsAuthenticationDomainService.authenticate_or_create(invalid_data)

    assert result.failure?
    assert_nil result.user
    assert_equal :invalid_auth_data, result.error
    assert_includes result.message, "Name can't be blank"
    assert_includes result.message, "Email can't be blank"
  end

  # =====================================
  # link_to_existing_user
  # =====================================

  test "既存ユーザーにGoogleアカウントを連携できる" do
    user = users(:one)

    assert_difference "User::SnsCredential.count", 1 do
      result = User::SnsAuthenticationDomainService.link_to_existing_user(@omniauth_data, user)

      assert result.success?
      assert_equal user, result.user
      assert_nil result.error

      # SnsCredentialが作成されていることを確認
      credential = User::SnsCredential.find_by(provider: @omniauth_data.provider, uid: @omniauth_data.uid)
      assert_not_nil credential
      assert_equal user, credential.user
      assert_equal @omniauth_data.email, credential.email
    end
  end

  test "link_to_existing_user：認証データが不正な場合は失敗する" do
    user = users(:one)
    invalid_data = User::OmniauthData.new(
      provider: "google",
      uid: "123456789",
      name: nil,
      email: nil
    )

    assert_no_difference "User::SnsCredential.count" do
      result = User::SnsAuthenticationDomainService.link_to_existing_user(invalid_data, user)

      assert result.failure?
      assert_equal :invalid_auth_data, result.error
      assert_includes result.message, "認証データが不完全です"
    end
  end

  test "link_to_existing_user：既に別のユーザーに紐づいているGoogleアカウントの場合は失敗する" do
    other_user = User.create!(name: "Other User")
    User::SnsCredential.create!(
      user: other_user,
      provider: @omniauth_data.provider,
      uid: @omniauth_data.uid,
      email: @omniauth_data.email
    )

    current_user = users(:one)

    assert_no_difference "User::SnsCredential.count" do
      result = User::SnsAuthenticationDomainService.link_to_existing_user(@omniauth_data, current_user)

      assert result.failure?
      assert_equal :validation_error, result.error
    end
  end

  test "link_to_existing_user：既に同じユーザーに紐づいているGoogleアカウントの場合は失敗する" do
    user = users(:one)
    User::SnsCredential.create!(
      user: user,
      provider: @omniauth_data.provider,
      uid: @omniauth_data.uid,
      email: @omniauth_data.email
    )

    assert_no_difference "User::SnsCredential.count" do
      result = User::SnsAuthenticationDomainService.link_to_existing_user(@omniauth_data, user)

      assert result.failure?
      assert_equal :validation_error, result.error
    end
  end
end
