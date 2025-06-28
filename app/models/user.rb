class User < ApplicationRecord
  devise :authenticatable

  has_one :database_authentication, dependent: :destroy

  before_validation :trim_name

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false },
                   length: { maximum: 255 }

  private

  def trim_name
    self.name = name&.strip
  end
end
