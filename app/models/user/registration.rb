class User::Registration < ApplicationRecord
  devise :confirmable

  before_validation :trim_email

  private

  def trim_email
    self.email = email&.strip
  end
end
