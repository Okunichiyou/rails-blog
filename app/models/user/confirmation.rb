class User::Confirmation < ApplicationRecord
  devise :confirmable

  before_validation :trim_email, :trim_unconfirmed_email

  private

  # @rbs () -> String?
  def trim_email
    self.email = email&.strip
  end

  # @rbs () -> String?
  def trim_unconfirmed_email
    self.unconfirmed_email = unconfirmed_email&.strip
  end
end
