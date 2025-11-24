# frozen_string_literal: true

# OmniAuthから取得した認証データを表すValue Object
class User::OmniauthData
  include ActiveModel::Model

  attr_reader :provider, :uid, :name, :email

  validates :provider, presence: true
  validates :uid, presence: true
  validates :name, presence: true
  validates :email, presence: true

  # @param auth [OmniAuth::AuthHash] OmniAuthのハッシュデータ
  # @return [User::OmniauthData]
  def self.from_omniauth(auth)
    new(
      provider: auth.provider,
      uid: auth.uid,
      name: auth.info && auth.info["name"],
      email: auth.info && auth.info["email"]
    )
  end

  def initialize(provider:, uid:, name:, email:)
    @provider = provider
    @uid = uid
    @name = name
    @email = email
  end
end
