class SnsCredential < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true
  validates :email, presence: true
  validates :uid, uniqueness: { scope: :provider }
  validates :email, uniqueness: { scope: :provider }
end
