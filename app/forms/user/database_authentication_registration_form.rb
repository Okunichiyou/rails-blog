class User::DatabaseAuthenticationRegistrationForm < ApplicationForm
  attribute :user_name, :string
  attribute :password, :string
  attribute :password_confirmation, :string
  attribute :confirmation_token, :string

  attr_reader :user, :user_database_authentication

  validate :validate_token
  validate :validate_email_duplication
  validates_associated :user, attribute_mapping: { name: :user_name }
  validates_associated :user_database_authentication

  # @rbs () -> String?
  def email
    confirmation_resource&.email
  end

  # @rbs () -> bool
  def save
    build_models
    return false unless valid?

    save_models
  end

  # @rbs () -> void
  def validate_token
    found_resource = User::Confirmation.find_by(confirmation_token:)

    if found_resource.nil?
      errors.add(:confirmation_token, :not_found, message: "が見つかりません")
      return
    end

    unless found_resource.confirmed?
      errors.add(:confirmation_token, :not_confirmed, message: "が確認されていません")
      nil
    end
  end

  # @rbs () -> void
  def validate_email_duplication
    return unless User::DuplicateEmailChecker.duplicate?(email)

    errors.add(:email, :already_used, message: "は既に使用されています")
  end

  private

  # @rbs () -> void
  def build_models
    @user = User.new(name: user_name)
    @user_database_authentication = User::DatabaseAuthentication.new(
      user: user,
      email: email,
      password: password,
      password_confirmation: password_confirmation
    )
  end

  # @rbs () -> bool
  def save_models
    ActiveRecord::Base.transaction do
      user.save!
      user_database_authentication.save!

      confirmation_resource&.destroy!

      true
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  # @rbs () -> User::Confirmation?
  def confirmation_resource
    @confirmation_resource ||= User::Confirmation.find_by(confirmation_token:)
  end
end
