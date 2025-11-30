# frozen_string_literal: true

# SNS認証に関するドメインロジックを扱うサービス
class User::SnsAuthenticationDomainService
  # SNS認証を行い、ユーザーを取得または作成する
  #
  # @param omniauth_data [User::OmniauthData] OmniAuth認証データ
  # @return [Result] 成功の場合はuserを含む、失敗の場合はerrorを含む
  # @rbs (User::OmniauthData) -> User::SnsAuthenticationDomainService::Result
  def self.authenticate_or_create(omniauth_data)
    new.authenticate_or_create(omniauth_data)
  end

  # @rbs (User::OmniauthData) -> User::SnsAuthenticationDomainService::Result
  def authenticate_or_create(omniauth_data)
    # OmniAuthデータの検証
    unless omniauth_data.valid?
      return Result.failure(
        error: :invalid_auth_data,
        message: "認証データが不完全です (#{omniauth_data.errors.full_messages.join(', ')})"
      )
    end

    # 既存のSNS認証情報を検索
    sns_credential = User::SnsCredential.find_by(
      provider: omniauth_data.provider,
      uid: omniauth_data.uid
    )

    if sns_credential
      # 既存ユーザーの場合
      Result.success(user: sns_credential.user)
    else
      # 新規ユーザーの場合：一時テーブルに保存してユーザー名編集フォームへ
      create_pending_registration(omniauth_data)
    end
  end

  # 一時登録トークンからユーザーを作成
  #
  # @param token [String] 一時登録トークン
  # @param user_name [String] ユーザーが編集したユーザー名
  # @return [Result] 成功の場合はuserを含む、失敗の場合はerrorを含む
  # @rbs (String, String) -> User::SnsAuthenticationDomainService::Result
  def self.create_from_pending(token, user_name)
    new.create_from_pending(token, user_name)
  end

  # @rbs (String, String) -> User::SnsAuthenticationDomainService::Result
  def create_from_pending(token, user_name)
    # 一時登録データを取得
    pending = User::PendingSnsCredential.find_valid_by_token(token)

    unless pending
      return Result.failure(
        error: :token_not_found_or_expired,
        message: "登録トークンが見つからないか、有効期限が切れています"
      )
    end

    # メールアドレス重複チェック
    if User::DuplicateEmailChecker.duplicate?(pending.email)
      return Result.failure(
        error: :email_already_used,
        message: "既に同じメールアドレスでアカウントが連携されています"
      )
    end

    # ユーザーとSNS認証情報を作成
    user = nil
    ActiveRecord::Base.transaction do
      user = User.create!(name: user_name)
      User::SnsCredential.create!(
        user: user,
        provider: pending.provider,
        uid: pending.uid,
        email: pending.email
      )
      pending.destroy!
    end

    Result.success(user: user)
  rescue ActiveRecord::RecordNotFound
    Result.failure(
      error: :token_not_found_or_expired,
      message: "登録トークンが見つからないか、有効期限が切れています"
    )
  rescue ActiveRecord::RecordInvalid => e
    Result.failure(
      error: :validation_error,
      message: e.message
    )
  end

  private

  # @rbs (User::OmniauthData) -> User::SnsAuthenticationDomainService::Result
  def create_pending_registration(omniauth_data)
    # メールアドレスが既に使用されているかチェック
    if User::DuplicateEmailChecker.duplicate?(omniauth_data.email)
      return Result.failure(
        error: :email_already_used,
        message: "既に同じメールアドレスでアカウントが連携されています"
      )
    end

    # 一時テーブルに保存
    pending = User::PendingSnsCredential.create_from_omniauth!(omniauth_data)
    Result.pending_registration(token: pending.token)
  rescue ActiveRecord::RecordInvalid => e
    Result.failure(
      error: :validation_error,
      message: e.message
    )
  end

  # SNS認証の結果を格納する
  # success = true:  認証完了してログインできる状態
  # success = false: 認証に失敗
  # pending = true:  SNS認証は完了したが、ユーザー情報の入力がこれから必要な状態
  Result = Data.define(
    :success, #: bool
    :user,    #: User?
    :error,   #: Symbol?
    :message, #: String?
    :token,   #: String?
    :pending  #: bool
  ) do
    # @rbs (user: User) -> User::SnsAuthenticationDomainService::Result
    def self.success(user:)
      new(success: true, user: user, error: nil, message: nil, token: nil, pending: false)
    end

    # @rbs (error: Symbol, message: String) -> User::SnsAuthenticationDomainService::Result
    def self.failure(error:, message:)
      new(success: false, user: nil, error: error, message: message, token: nil, pending: false)
    end

    # @rbs (token: String) -> User::SnsAuthenticationDomainService::Result
    def self.pending_registration(token:)
      new(success: false, user: nil, error: nil, message: nil, token: token, pending: true)
    end

    # @rbs () -> bool
    def success?
      success
    end

    # @rbs () -> bool
    def failure?
      !success && !pending
    end

    # @rbs () -> bool
    def pending_registration?
      pending
    end
  end
end
