class User::DatabaseAuthenticationRegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user_name, :string
  attribute :password, :string
  attribute :password_confirmation, :string
  attribute :confirmation_token, :string

  attr_reader :user, :user_database_authentication

  validate :validate_token
  validate :validate_email_duplication
  validate :validate_user
  validate :validate_database_authentication

  # Userモデル属性からフォーム属性へのマッピング
  USER_ATTR_TRANSFORM_MAP = {
    name: :user_name
  }.freeze

  # @rbs () -> ActiveModel::Name
  def model_name
    ActiveModel::Name.new(self, nil, "Confirmation")
  end

  # @rbs () -> String?
  def email
    confirmation_resource&.email
  end

  # @rbs () -> bool
  def call
    build_models
    return false unless valid?

    save_models
  end

  # @rbs () -> nil
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

  # @rbs () -> User::DatabaseAuthentication
  def build_models
    @user = User.new(name: user_name)
    @user_database_authentication = User::DatabaseAuthentication.new(
      user: user,
      email: email,
      password: password,
      password_confirmation: password_confirmation
    )
  end

  # @rbs () -> Array[untyped]?
  def validate_user
    return unless @user # モデルが構築されていない場合はスキップ
    return if user.valid?

    user.errors.each do |error|
      attribute = USER_ATTR_TRANSFORM_MAP[error.attribute] || error.attribute
      errors.add(attribute, error.type, message: error.message)
    end
  end

  # @rbs () -> Array[untyped]?
  def validate_database_authentication
    return unless @user_database_authentication # モデルが構築されていない場合はスキップ
    return if user_database_authentication.valid?

    user_database_authentication.errors.each do |error|
      errors.add(error.attribute, error.type, message: error.message)
    end
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
