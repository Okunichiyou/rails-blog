class User::DatabaseAuthenticationLinkForm < ApplicationForm
  attribute :password, :string
  attribute :password_confirmation, :string
  attribute :confirmation_token, :string

  attr_reader :current_user, :user_database_authentication

  validate :validate_token
  validate :validate_database_authentication
  validate :validate_current_user

  # @rbs (current_user: User) -> void
  def initialize(current_user:, **attributes)
    @current_user = current_user
    super(**attributes)
  end

  # @rbs () -> ActiveModel::Name
  def model_name
    ActiveModel::Name.new(self, nil, "Confirmation")
  end

  # @rbs () -> String?
  def email
    confirmation_resource&.email
  end

  # @rbs () -> String?
  def user_name
    current_user&.name
  end

  # @rbs () -> bool
  def save
    build_models
    return false unless valid?

    save_models
  end

  # @rbs () -> nil
  def validate_token
    found_resource = User::Confirmation.find_by(confirmation_token:)

    if found_resource.nil?
      errors.add(:base, :token_not_found, message: "認証トークンが見つかりません")
      return
    end

    unless found_resource.confirmed?
      errors.add(:base, :not_confirmed, message: "認証トークンが確認されていません")
      nil
    end
  end

  # @rbs () -> void
  def validate_current_user
    if current_user.nil?
      errors.add(:base, :current_user_required, message: "ログインが必要です")
      return
    end

    if current_user.database_authenticated?
      errors.add(:base, :already_linked, message: "既にメール認証がリンクされています")
    end
  end

  private

  # @rbs () -> User::DatabaseAuthentication
  def build_models
    @user_database_authentication = User::DatabaseAuthentication.new(
      user: current_user,
      email: email,
      password: password,
      password_confirmation: password_confirmation
    )
  end

  # @rbs () -> void
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
