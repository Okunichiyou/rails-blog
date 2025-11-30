class User < ApplicationRecord
  devise :authenticatable

  has_one :database_authentication, dependent: :destroy
  has_many :sns_credentials, dependent: :destroy

  before_validation :trim_name

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false },
                   length: { maximum: 255 }

  # @rbs () -> bool
  def google_linked?
    sns_credentials.exists?(provider: "google_oauth2")
  end

  private

  # @rbs () -> String?
  def trim_name
    self.name = name&.strip
  end
end
