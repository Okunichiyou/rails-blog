class User::EmailConfirmationForm < ApplicationForm
  attribute :email, :string

  validates :email, presence: true
  validate :validate_user_confirmation

  # @rbs () -> bool
  def save
    return false unless valid?

    user_confirmation.save
  end

  private

  # @rbs () -> User::Confirmation
  def user_confirmation
    @user_confirmation ||= User::Confirmation.find_or_initialize_by(unconfirmed_email: email)
  end

  # @rbs () -> void
  def validate_user_confirmation
    return if email.blank?

    validate_model(user_confirmation, attribute_map: { unconfirmed_email: :email })
  end
end
