require "test_helper"

class User::OmniauthDataTest < ActiveSupport::TestCase
  test "valid with all required attributes" do
    omniauth_data = User::OmniauthData.new(
      provider: "google",
      uid: "123456789",
      name: "Test User",
      email: "test@example.com"
    )

    assert omniauth_data.valid?
    assert_empty omniauth_data.errors
  end

  test "invalid without provider" do
    omniauth_data = User::OmniauthData.new(
      provider: nil,
      uid: "123456789",
      name: "Test User",
      email: "test@example.com"
    )

    assert_not omniauth_data.valid?
    assert_includes omniauth_data.errors[:provider], "を入力してください"
  end

  test "invalid without uid" do
    omniauth_data = User::OmniauthData.new(
      provider: "google",
      uid: nil,
      name: "Test User",
      email: "test@example.com"
    )

    assert_not omniauth_data.valid?
    assert_includes omniauth_data.errors[:uid], "を入力してください"
  end

  test "invalid without name" do
    omniauth_data = User::OmniauthData.new(
      provider: "google",
      uid: "123456789",
      name: nil,
      email: "test@example.com"
    )

    assert_not omniauth_data.valid?
    assert_includes omniauth_data.errors[:name], "を入力してください"
  end

  test "invalid without email" do
    omniauth_data = User::OmniauthData.new(
      provider: "google",
      uid: "123456789",
      name: "Test User",
      email: nil
    )

    assert_not omniauth_data.valid?
    assert_includes omniauth_data.errors[:email], "を入力してください"
  end

  test "from_omniauth creates OmniauthData from OmniAuth hash" do
    auth_hash = OmniAuth::AuthHash.new(
      provider: "google",
      uid: "123456789",
      info: {
        name: "Test User",
        email: "test@example.com"
      }
    )

    omniauth_data = User::OmniauthData.from_omniauth(auth_hash)

    assert_equal "google", omniauth_data.provider
    assert_equal "123456789", omniauth_data.uid
    assert_equal "Test User", omniauth_data.name
    assert_equal "test@example.com", omniauth_data.email
  end

  test "from_omniauth handles missing info" do
    auth_hash = OmniAuth::AuthHash.new(
      provider: "google",
      uid: "123456789",
      info: nil
    )

    omniauth_data = User::OmniauthData.from_omniauth(auth_hash)

    assert_equal "google", omniauth_data.provider
    assert_equal "123456789", omniauth_data.uid
    assert_nil omniauth_data.name
    assert_nil omniauth_data.email
    assert_not omniauth_data.valid?
  end

  test "attributes are read-only" do
    omniauth_data = User::OmniauthData.new(
      provider: "google",
      uid: "123456789",
      name: "Test User",
      email: "test@example.com"
    )

    assert_not_respond_to omniauth_data, :provider=
    assert_not_respond_to omniauth_data, :uid=
    assert_not_respond_to omniauth_data, :name=
    assert_not_respond_to omniauth_data, :email=
  end
end
