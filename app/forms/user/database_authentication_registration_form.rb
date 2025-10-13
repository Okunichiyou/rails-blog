class User::DatabaseAuthenticationRegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user_name, :string
  attribute :email, :string
  attribute :password, :string
  attribute :password_confirmation, :string
  attribute :confirmation_token, :string

  # Userモデル属性からフォーム属性へのマッピング
  USER_ATTR_TRANSFORM_MAP = {
    name: :user_name
  }.freeze

  def model_name
    ActiveModel::Name.new(self, nil, "Registration")
  end

  def call
    build_models
    return false unless validate_all_models

    save_models
  end

  def user
    @user
  end

  def user_database_authentication
    @user_database_authentication
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

  def validate_all_models
    user_valid = validate_user
    auth_valid = validate_database_authentication
    user_valid && auth_valid
  end

  def validate_user
    return true if @user.valid?

    @user.errors.each do |error|
      attribute = USER_ATTR_TRANSFORM_MAP[error.attribute] || error.attribute
      errors.add(attribute, error.type, message: error.message)
    end
    false
  end

  def validate_database_authentication
    return true if @user_database_authentication.valid?

    @user_database_authentication.errors.each do |error|
      errors.add(error.attribute, error.type, message: error.message)
    end
    false
  end

  def save_models
    ActiveRecord::Base.transaction do
      @user.save!
      @user_database_authentication.save!

      resource = User::Registration.find_by_confirmation_token(confirmation_token)
      resource&.destroy!

      true
    end
  rescue ActiveRecord::RecordInvalid
    false
  end
end
