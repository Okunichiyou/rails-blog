require "test_helper"

class User::SnsCredentialTest < ActiveSupport::TestCase
  # @rbs () -> User::SnsCredential
  def setup
    @user = users(:one)
    @sns_credential = User::SnsCredential.new(
      user: @user,
      provider: "google",
      uid: "123456789",
      email: "test@example.com"
    )
  end

  test "should be valid with valid attributes" do
    assert @sns_credential.valid?
  end

  # presenceバリデーション
  test "should require user" do
    @sns_credential.user = nil
    assert_not @sns_credential.valid?
    assert_includes @sns_credential.errors[:user], "を入力してください"
  end

  test "should require provider" do
    @sns_credential.provider = nil
    assert_not @sns_credential.valid?
    assert_includes @sns_credential.errors[:provider], "を入力してください"
  end

  test "should require uid" do
    @sns_credential.uid = nil
    assert_not @sns_credential.valid?
    assert_includes @sns_credential.errors[:uid], "を入力してください"
  end

  test "should require email" do
    @sns_credential.email = nil
    assert_not @sns_credential.valid?
    assert_includes @sns_credential.errors[:email], "を入力してください"
  end

  # uniquenessバリデーション: provider + uid
  test "should require unique combination of provider and uid" do
    @sns_credential.save!
    duplicate = User::SnsCredential.new(
      user: @user,
      provider: @sns_credential.provider,
      uid: @sns_credential.uid,
      email: "different@example.com"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:uid], "はすでに存在します"
  end

  test "should allow same uid with different provider" do
    @sns_credential.save!
    different_provider = User::SnsCredential.new(
      user: @user,
      provider: "github",
      uid: @sns_credential.uid,
      email: "github@example.com"
    )
    assert different_provider.valid?
  end

  # uniquenessバリデーション: provider + email
  test "should require unique combination of provider and email" do
    @sns_credential.save!
    duplicate = User::SnsCredential.new(
      user: @user,
      provider: @sns_credential.provider,
      uid: "different_uid",
      email: @sns_credential.email
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "はすでに存在します"
  end

  test "should allow same email with different provider" do
    @sns_credential.save!
    different_provider = User::SnsCredential.new(
      user: @user,
      provider: "github",
      uid: "987654321",
      email: @sns_credential.email
    )
    assert different_provider.valid?
  end

  # associationのテスト
  test "should belong to user" do
    assert_respond_to @sns_credential, :user
  end

  test "should be destroyed when user is destroyed" do
    @sns_credential.save!
    assert_difference("User::SnsCredential.count", -1) do
      @user.destroy
    end
  end
end
