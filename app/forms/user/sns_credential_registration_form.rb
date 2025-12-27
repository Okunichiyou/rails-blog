class User::SnsCredentialRegistrationForm < ApplicationForm
  attribute :user_name, :string
  attribute :token, :string

  attr_reader :user, :pending_credential

  validates :user_name, presence: true, unless: -> { validation_context == :token_validation_only }
  validates :token, presence: true
  validate :validate_token
  validate :validate_user, unless: -> { validation_context == :token_validation_only }

  # @rbs () -> ActiveModel::Name
  def model_name
    ActiveModel::Name.new(self, nil, "SnsCredentialRegistration")
  end

  # @rbs () -> String?
  def email
    @pending_credential&.email
  end

  # @rbs () -> String
  def provider
    @pending_credential&.provider
  end

  # @rbs () -> bool
  def save
    return false unless valid?

    result = User::SnsAuthenticationDomainService.create_from_pending(token, user_name)

    if result.success?
      @user = result.user
      true
    else
      errors.add(:base, result.message)
      false
    end
  end

  private

  # @rbs () -> ActiveModel::Error?
  def validate_token
    @pending_credential = User::PendingSnsCredential.find_by(token: token)

    if @pending_credential.nil?
      errors.add(:token, :not_found, message: "が見つかりません")
      return
    end

    if @pending_credential.expired?
      errors.add(:token, :expired, message: "の有効期限が切れています")
    end
  end

  # @rbs () -> Array[untyped]?
  def validate_user
    return unless @pending_credential # pending_credentialが見つからない場合はスキップ

    temp_user = User.new(name: user_name)
    return if temp_user.valid?

    temp_user.errors.each do |error|
      errors.add(:user_name, error.type, message: error.message)
    end
  end
end
