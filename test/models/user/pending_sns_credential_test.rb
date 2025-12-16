require "test_helper"

class User::PendingSnsCredentialTest < ActiveSupport::TestCase
  test "必須項目のバリデーション" do
    pending = User::PendingSnsCredential.new
    assert_not pending.valid?
    assert_includes pending.errors[:token], "を入力してください"
    assert_includes pending.errors[:provider], "を入力してください"
    assert_includes pending.errors[:uid], "を入力してください"
    assert_includes pending.errors[:email], "を入力してください"
    assert_includes pending.errors[:name], "を入力してください"
    assert_includes pending.errors[:expires_at], "を入力してください"
  end

  test "トークンの一意性バリデーション" do
    pending1 = user_pending_sns_credentials(:one)
    pending2 = User::PendingSnsCredential.new(
      token: pending1.token,
      provider: "google_oauth2",
      uid: "999",
      email: "test@example.com",
      name: "Test",
      expires_at: 10.minutes.from_now
    )
    assert_not pending2.valid?
    assert_includes pending2.errors[:token], "はすでに存在します"
  end

  test "create_from_omniauth! でOmniauthDataから作成できる" do
    omniauth_data = User::OmniauthData.new(
      provider: "google_oauth2",
      uid: "123456",
      email: "new@example.com",
      name: "New User"
    )

    pending = User::PendingSnsCredential.create_from_omniauth!(omniauth_data)

    assert pending.persisted?
    assert_equal "google_oauth2", pending.provider
    assert_equal "123456", pending.uid
    assert_equal "new@example.com", pending.email
    assert_equal "New User", pending.name
    assert pending.token.present?
    assert pending.expires_at > Time.current
  end

  test "expired? で期限切れを判定できる" do
    expired = user_pending_sns_credentials(:expired)
    valid = user_pending_sns_credentials(:one)

    assert expired.expired?
    assert_not valid.expired?
  end

  test "expired スコープで期限切れレコードのみ取得できる" do
    expired_records = User::PendingSnsCredential.expired
    assert_includes expired_records, user_pending_sns_credentials(:expired)
    assert_not_includes expired_records, user_pending_sns_credentials(:one)
  end

  test "find_valid_by_token で有効なトークンを取得できる" do
    valid = user_pending_sns_credentials(:one)
    found = User::PendingSnsCredential.find_valid_by_token(valid.token)
    assert_equal valid.id, found.id
  end

  test "find_valid_by_token で期限切れトークンはエラー" do
    expired = user_pending_sns_credentials(:expired)
    assert_raises(ActiveRecord::RecordNotFound) do
      User::PendingSnsCredential.find_valid_by_token(expired.token)
    end
  end

  test "find_valid_by_token で存在しないトークンはnilを返してエラーにならない" do
    result = User::PendingSnsCredential.find_valid_by_token("nonexistent")
    assert_nil result
  end

  test "to_omniauth_data でOmniauthDataに変換できる" do
    pending = user_pending_sns_credentials(:one)
    omniauth_data = pending.to_omniauth_data

    assert_instance_of User::OmniauthData, omniauth_data
    assert_equal pending.provider, omniauth_data.provider
    assert_equal pending.uid, omniauth_data.uid
    assert_equal pending.email, omniauth_data.email
    assert_equal pending.name, omniauth_data.name
  end
end
