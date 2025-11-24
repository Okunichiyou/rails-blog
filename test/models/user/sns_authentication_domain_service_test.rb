require "test_helper"

class User::SnsAuthenticationDomainServiceTest < ActiveSupport::TestCase
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

  test "authenticate_or_create creates new user when sns_credential does not exist" do
    assert_difference [ "User.count", "User::SnsCredential.count" ], 1 do
      result = User::SnsAuthenticationDomainService.authenticate_or_create(@omniauth_data)

      assert result.success?
      assert_not_nil result.user
      assert_equal @omniauth_data.name, result.user.name
      assert_nil result.error
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
    assert_equal "既に同じメールアドレスでアカウントが連携されています", result.message
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
    assert_equal "既に同じメールアドレスでアカウントが連携されています", result.message
  end

  test "authenticate_or_create creates both user and sns_credential in transaction" do
    assert_difference "User.count", 1 do
      assert_difference "User::SnsCredential.count", 1 do
        result = User::SnsAuthenticationDomainService.authenticate_or_create(@omniauth_data)

        assert result.success?
        created_user = result.user
        created_credential = User::SnsCredential.find_by(uid: @omniauth_data.uid)

        assert_equal created_user, created_credential.user
        assert_equal @omniauth_data.provider, created_credential.provider
        assert_equal @omniauth_data.uid, created_credential.uid
        assert_equal @omniauth_data.email, created_credential.email
      end
    end
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
end
