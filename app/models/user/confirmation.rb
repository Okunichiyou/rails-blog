class User::Confirmation < ApplicationRecord
  devise :confirmable

  before_validation :trim_email, :trim_unconfirmed_email

  validates :unconfirmed_email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { unconfirmed_email.present? }

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
