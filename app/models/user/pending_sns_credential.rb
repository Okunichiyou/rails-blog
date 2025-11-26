class User::PendingSnsCredential < ApplicationRecord
  # トークンの有効期限（デフォルト10分）
  TOKEN_EXPIRATION_TIME = 10.minutes

  validates :token, presence: true, uniqueness: true
  validates :provider, presence: true
  validates :uid, presence: true
  validates :email, presence: true
  validates :name, presence: true
  validates :expires_at, presence: true

  # 期限切れレコードを削除
  scope :expired, -> { where("expires_at < ?", Time.current) }

  # トークンから有効なレコードを検索
  # @rbs (String) -> User::PendingSnsCredential?
  def self.find_valid_by_token(token)
    find_by(token: token)&.tap do |record|
      raise ActiveRecord::RecordNotFound if record.expired?
    end
  end

  # OmniAuthDataから作成
  # @rbs (User::OmniauthData) -> User::PendingSnsCredential
  def self.create_from_omniauth!(omniauth_data)
    create!(
      token: generate_secure_token,
      provider: omniauth_data.provider,
      uid: omniauth_data.uid,
      email: omniauth_data.email,
      name: omniauth_data.name,
      expires_at: TOKEN_EXPIRATION_TIME.from_now
    )
  end

  # 期限切れかどうか
  # @rbs () -> bool
  def expired?
    expires_at < Time.current
  end

  # OmniauthDataオブジェクトに変換
  # @rbs () -> User::OmniauthData
  def to_omniauth_data
    User::OmniauthData.new(
      provider: provider,
      uid: uid,
      email: email,
      name: name
    )
  end

  private

  # @rbs () -> String
  def self.generate_secure_token
    SecureRandom.urlsafe_base64(32)
  end
end
