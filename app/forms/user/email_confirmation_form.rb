class User::EmailConfirmationForm < ApplicationForm
  include ActiveModel::Validations::Callbacks

  attribute :email, :string

  before_validation :trim_email

  validates :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email.present? }

  # @rbs () -> ActiveModel::Name
  def model_name
    ActiveModel::Name.new(self, nil, "Confirmation")
  end

  # @rbs () -> bool
  def save
    return false unless valid?

    user_confirmation = User::Confirmation.find_or_initialize_by(unconfirmed_email: email)
    user_confirmation.save
  end

  private

  # @rbs () -> String
  def trim_email
    self.email = email&.strip
  end
end
