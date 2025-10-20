class User::EmailConfirmationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attribute :email, :string

  before_validation :trim_email

  validates :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email.present? }

  def model_name
    ActiveModel::Name.new(self, nil, "Confirmation")
  end

  def call
    return false unless valid?

    user_confirmation = User::Confirmation.find_or_initialize_by(unconfirmed_email: email)
    user_confirmation.save
  end

  private

  def trim_email
    self.email = email&.strip
  end
end
