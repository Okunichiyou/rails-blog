class User::DatabaseAuthenticationRegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user_name, :string
  attribute :password, :string
  attribute :password_confirmation, :string
  attribute :confirmation_token, :string

  attr_reader :user, :user_database_authentication

  validate :validate_user
  validate :validate_database_authentication

  # Userモデル属性からフォーム属性へのマッピング
  USER_ATTR_TRANSFORM_MAP = {
    name: :user_name
  }.freeze

  def model_name
    ActiveModel::Name.new(self, nil, "Confirmation")
  end

  def email
    confirmation_resource&.email
  end

  def call
    build_models
    return false unless valid?

    save_models
  end

  def validate_token
    found_resource = User::Confirmation.find_by(confirmation_token:)

    if found_resource.nil?
      return :not_found
    end

    unless found_resource.confirmed?
      return :unprocessable_entity
    end

    nil
  end

  private

  def build_models
    @user = User.new(name: user_name)
    @user_database_authentication = User::DatabaseAuthentication.new(
      user: @user,
      email: email,
      password: password,
      password_confirmation: password_confirmation
    )
  end

  def validate_user
    return if @user.valid?

    @user.errors.each do |error|
      attribute = USER_ATTR_TRANSFORM_MAP[error.attribute] || error.attribute
      errors.add(attribute, error.type, message: error.message)
    end
  end

  def validate_database_authentication
    return if @user_database_authentication.valid?

    @user_database_authentication.errors.each do |error|
      errors.add(error.attribute, error.type, message: error.message)
    end
  end

  def save_models
    ActiveRecord::Base.transaction do
      @user.save!
      @user_database_authentication.save!

      confirmation_resource&.destroy!

      true
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  def confirmation_resource
    @confirmation_resource ||= User::Confirmation.find_by(confirmation_token:)
  end
end
