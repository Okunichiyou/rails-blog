require "test_helper"

class User::ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  # =====================================
  # createアクション（確認メール送信）
  # =====================================

  test "POST /confirmations/confirmation 新規メールアドレスで確認メール送信" do
    email = "new@example.com"

    assert_difference "User::Confirmation.count", 1 do
      post confirmation_confirmation_path, params: { confirmation: { email: email } }
    end

    assert_redirected_to email_confirmation_sent_path

    confirmation = User::Confirmation.find_by(unconfirmed_email: email)
    assert_not_nil confirmation
    assert_not_nil confirmation.confirmation_token
  end

  test "POST /confirmations/confirmation 既存の未確認メールアドレスで再送信" do
    User::Confirmation.create!(
      unconfirmed_email: "existing@example.com",
      confirmation_token: "existing_token"
    )

    assert_no_difference "User::Confirmation.count" do
      post confirmation_confirmation_path, params: { confirmation: { email: "existing@example.com" } }
    end

    assert_redirected_to email_confirmation_sent_path
  end

  test "POST /confirmations/confirmation 空のメールアドレスでバリデーションエラー" do
    assert_no_difference "User::Confirmation.count" do
      post confirmation_confirmation_path, params: { confirmation: { email: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "POST /confirmations/confirmation 無効な形式のメールアドレスでバリデーションエラー" do
    assert_no_difference "User::Confirmation.count" do
      post confirmation_confirmation_path, params: { confirmation: { email: "invalid-email" } }
    end

    assert_response :unprocessable_entity
  end

  # =====================================
  # confirmアクション（確認完了）
  # =====================================

  test "GET /confirmations/confirmation 有効なトークンで確認画面へリダイレクト" do
    User::Confirmation.create!(
      unconfirmed_email: "confirm@example.com",
      confirmation_token: "valid_token"
    )

    get confirmation_confirmation_path, params: { confirmation_token: "valid_token" }

    assert_redirected_to new_user_database_authentication_path(confirmation_token: "valid_token")
  end

  test "GET /confirmations/confirmation 無効なトークンでもリダイレクト" do
    get confirmation_confirmation_path, params: { confirmation_token: "invalid_token" }

    # Deviseは無効なトークンでも新しいトークンを生成してリダイレクトする
    assert_response :redirect
  end

  test "GET /confirmations/confirmation 30分経過したトークンでもリダイレクト" do
    User::Confirmation.create!(
      unconfirmed_email: "expired30@example.com",
      confirmation_token: "expired_30min_token",
      confirmation_sent_at: 30.minutes.ago
    )

    get confirmation_confirmation_path, params: { confirmation_token: "expired_30min_token" }

    # Deviseは期限切れトークンでも新しいトークンを生成してリダイレクトする
    assert_response :redirect
  end

  test "GET /confirmations/confirmation 31分経過したトークンでもリダイレクト" do
    User::Confirmation.create!(
      unconfirmed_email: "expired31@example.com",
      confirmation_token: "expired_31min_token",
      confirmation_sent_at: 31.minutes.ago
    )

    get confirmation_confirmation_path, params: { confirmation_token: "expired_31min_token" }

    # Deviseは期限切れトークンでも新しいトークンを生成してリダイレクトする
    assert_response :redirect
  end
end
