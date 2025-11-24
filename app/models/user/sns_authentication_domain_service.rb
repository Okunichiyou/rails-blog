# frozen_string_literal: true

# SNS認証に関するドメインロジックを扱うサービス
class User::SnsAuthenticationDomainService
  # SNS認証を行い、ユーザーを取得または作成する
  #
  # @param omniauth_data [User::OmniauthData] OmniAuth認証データ
  # @return [Result] 成功の場合はuserを含む、失敗の場合はerrorを含む
  def self.authenticate_or_create(omniauth_data)
    new.authenticate_or_create(omniauth_data)
  end

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
      # 新規ユーザーの場合：メールアドレス重複チェック
      create_new_user(omniauth_data)
    end
  end

  private

  def create_new_user(omniauth_data)
    # メールアドレスが既に使用されているかチェック
    if email_already_used?(omniauth_data.email)
      return Result.failure(
        error: :email_already_used,
        message: "既に同じメールアドレスでアカウントが連携されています"
      )
    end

    # 新規ユーザーとSNS認証情報を作成
    user = nil
    ActiveRecord::Base.transaction do
      user = User.create!(name: omniauth_data.name)
      User::SnsCredential.create!(
        user: user,
        provider: omniauth_data.provider,
        uid: omniauth_data.uid,
        email: omniauth_data.email
      )
    end

    Result.success(user: user)
  rescue ActiveRecord::RecordInvalid => e
    Result.failure(
      error: :validation_error,
      message: e.message
    )
  end

  # メールアドレスが既に使用されているか確認
  #
  # @param email [String] チェックするメールアドレス
  # @return [Boolean] 使用されている場合true
  def email_already_used?(email)
    # DatabaseAuthenticationまたはSnsCredentialでメールアドレスが使用されているか
    User::DatabaseAuthentication.exists?(email: email) ||
      User::SnsCredential.exists?(email: email)
  end

  # 結果オブジェクト
  class Result < Data.define(:success, :user, :error, :message)
    def self.success(user:)
      new(success: true, user: user, error: nil, message: nil)
    end

    def self.failure(error:, message:)
      new(success: false, user: nil, error: error, message: message)
    end

    def success?
      success
    end

    def failure?
      !success
    end
  end
end
