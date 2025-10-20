require "test_helper"

class User::ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  # =====================================
  # createアクション（確認メール送信）
  # =====================================

  test "POST /confirmations/confirmation 新規メールアドレスで確認メール送信" do
    email = "new@example.com"

    assert_difference "User::Confirmation.count", 1 do
      assert_emails 1 do
        post confirmation_confirmation_path, params: { confirmation: { email: email } }
      end
    end

    assert_redirected_to email_confirmation_sent_path

    confirmation = User::Confirmation.find_by(unconfirmed_email: email)
    assert_not_nil confirmation
    assert_not_nil confirmation.confirmation_token

    # 送信されたメールの内容を確認
    mail = ActionMailer::Base.deliveries.last
    assert_equal [ email ], mail.to
    assert_match /Confirmation/, mail.subject
  end

  test "POST /confirmations/confirmation 既存の未確認メールアドレスで再送信" do
    User::Confirmation.create!(
      unconfirmed_email: "existing@example.com",
      confirmation_token: "existing_token"
    )

    assert_no_difference "User::Confirmation.count" do
      assert_emails 1 do
        post confirmation_confirmation_path, params: { confirmation: { email: "existing@example.com" } }
      end
    end

    assert_redirected_to email_confirmation_sent_path

    # 送信されたメールの内容を確認
    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "existing@example.com" ], mail.to
    assert_match /Confirmation/, mail.subject
  end

  test "POST /confirmations/confirmation 空のメールアドレスでバリデーションエラー" do
    assert_no_difference "User::Confirmation.count" do
      assert_no_emails do
        post confirmation_confirmation_path, params: { confirmation: { email: "" } }
      end
    end

    assert_response :unprocessable_entity
  end

  test "POST /confirmations/confirmation 無効な形式のメールアドレスでバリデーションエラー" do
    assert_no_difference "User::Confirmation.count" do
      assert_no_emails do
        post confirmation_confirmation_path, params: { confirmation: { email: "invalid-email" } }
      end
    end

    assert_response :unprocessable_entity
  end

  # =====================================
  # confirmアクション（確認完了）
  # =====================================

  test "GET /confirmations/confirmation 有効なトークンで確認画面へリダイレクト" do
    confirmation = User::Confirmation.create!(
      unconfirmed_email: "confirm@example.com",
      confirmation_token: "valid_token"
    )

    get confirmation_confirmation_path, params: { confirmation_token: "valid_token" }

    assert_redirected_to new_user_database_authentication_path(confirmation_token: "valid_token")

    # メールアドレスの確認が完了している
    confirmation.reload
    assert_not_nil confirmation.confirmed_at
    assert_equal "valid_token", confirmation.confirmation_token
  end

  test "GET /confirmations/confirmation 無効なトークンでエラーメッセージ表示" do
    get confirmation_confirmation_path, params: { confirmation_token: "invalid_token" }

    # 無効なトークンの場合はエラーメッセージを表示
    assert_response :unprocessable_entity
    assert_select "h2", text: "メールアドレスの確認に失敗しました"
    assert_select "div.alert", text: /Confirmation token is invalid/
  end

  test "GET /confirmations/confirmation 30分丁度のトークンは有効（境界値を含む）" do
    travel_to Time.current do
      confirmation = User::Confirmation.create!(
        unconfirmed_email: "valid30@example.com",
        confirmation_token: "valid_30min_token",
        confirmation_sent_at: Time.current
      )

      # ちょうど30分後に移動
      travel 30.minutes

      get confirmation_confirmation_path, params: { confirmation_token: "valid_30min_token" }

      assert_redirected_to new_user_database_authentication_path(confirmation_token: "valid_30min_token")

      # メールアドレスの確認が完了している（30分丁度は有効）
      confirmation.reload
      assert_not_nil confirmation.confirmed_at
      assert_equal "valid_30min_token", confirmation.confirmation_token
    end
  end

  test "GET /confirmations/confirmation 30分1秒経過したトークンは無効でエラーメッセージ表示" do
    travel_to Time.current do
      confirmation = User::Confirmation.create!(
        unconfirmed_email: "expired30@example.com",
        confirmation_token: "expired_30min_1sec_token",
        confirmation_sent_at: Time.current
      )

      # 30分1秒後に移動
      travel 30.minutes + 1.second

      get confirmation_confirmation_path, params: { confirmation_token: "expired_30min_1sec_token" }

      # 期限切れの場合はエラーメッセージを表示
      assert_response :unprocessable_entity
      assert_select "h2", text: "メールアドレスの確認に失敗しました"
      assert_select "div.alert", text: /needs to be confirmed within/

      # メールアドレスの確認は完了していない
      confirmation.reload
      assert_nil confirmation.confirmed_at
      # トークンはそのまま（期限切れの場合は新しいトークンは生成されない）
      assert_equal "expired_30min_1sec_token", confirmation.confirmation_token
    end
  end
end
