class User::Registration < ApplicationRecord
  devise :confirmable

  before_validation :trim_email, :trim_unconfirmed_email

  private

  def trim_email
    self.email = email&.strip
  end

  def trim_unconfirmed_email
    self.unconfirmed_email = unconfirmed_email&.strip
  end
end
