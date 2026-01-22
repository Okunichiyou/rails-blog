class User::SnsCredential < ApplicationRecord
  belongs_to :user

  devise :omniauthable, omniauth_providers: %i[google_oauth2 apple]

  validates :provider, presence: true
  validates :uid, presence: true
  validates :email, presence: true
  validates :uid, uniqueness: { scope: :provider }
  validates :email, uniqueness: { scope: :provider }
end
