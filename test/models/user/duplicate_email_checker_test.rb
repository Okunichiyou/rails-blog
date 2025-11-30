require "test_helper"

class User::DuplicateEmailCheckerTest < ActiveSupport::TestCase
  # =====================================
  # 重複チェック - 正常系（重複なし）
  # =====================================

  test "どちらのテーブルにもメールアドレスが存在しない場合、falseを返す" do
    email = "unique@example.com"

    result = User::DuplicateEmailChecker.duplicate?(email)

    assert_equal false, result
  end

  test "空のメールアドレスの場合、falseを返す" do
    result = User::DuplicateEmailChecker.duplicate?("")

    assert_equal false, result
  end

  test "nilのメールアドレスの場合、falseを返す" do
    result = User::DuplicateEmailChecker.duplicate?(nil)

    assert_equal false, result
  end

  # =====================================
  # 重複チェック - DatabaseAuthenticationに存在する場合
  # =====================================

  test "DatabaseAuthenticationにメールアドレスが存在する場合、trueを返す" do
    user = User.create!(name: "test_user")
    email = "database_auth@example.com"
    User::DatabaseAuthentication.create!(
      user: user,
      email: email,
      password: "password123"
    )

    result = User::DuplicateEmailChecker.duplicate?(email)

    assert_equal true, result
  end

  test "DatabaseAuthenticationに大文字小文字が異なるメールアドレスが存在する場合でも正しく検出される" do
    user = User.create!(name: "test_user")
    User::DatabaseAuthentication.create!(
      user: user,
      email: "Case@Example.Com",
      password: "password123"
    )

    result = User::DuplicateEmailChecker.duplicate?("case@example.com")

    assert_equal true, result
  end

  # =====================================
  # 重複チェック - SnsCredentialに存在する場合
  # =====================================

  test "SnsCredentialにメールアドレスが存在する場合、trueを返す" do
    user = User.create!(name: "sns_user")
    email = "sns@example.com"
    User::SnsCredential.create!(
      user: user,
      provider: "google_oauth2",
      uid: "123456",
      email: email
    )

    result = User::DuplicateEmailChecker.duplicate?(email)

    assert_equal true, result
  end

  test "SnsCredentialに大文字小文字が異なるメールアドレスが存在する場合でも正しく検出される" do
    user = User.create!(name: "sns_user")
    User::SnsCredential.create!(
      user: user,
      provider: "google_oauth2",
      uid: "123456",
      email: "SNS@EXAMPLE.COM"
    )

    result = User::DuplicateEmailChecker.duplicate?("sns@example.com")

    assert_equal true, result
  end

  # =====================================
  # 重複チェック - 両方のテーブルに存在する場合
  # =====================================

  test "DatabaseAuthenticationとSnsCredentialの両方に同じメールアドレスが存在する場合、trueを返す" do
    user1 = User.create!(name: "db_user")
    user2 = User.create!(name: "sns_user")
    email = "both@example.com"

    User::DatabaseAuthentication.create!(
      user: user1,
      email: email,
      password: "password123"
    )
    User::SnsCredential.create!(
      user: user2,
      provider: "google_oauth2",
      uid: "123456",
      email: email
    )

    result = User::DuplicateEmailChecker.duplicate?(email)

    assert_equal true, result
  end

  # =====================================
  # 複数レコードのテスト
  # =====================================

  test "DatabaseAuthenticationに複数のレコードが存在しても、検索対象のメールアドレスが存在しない場合はfalseを返す" do
    user1 = User.create!(name: "user1")
    user2 = User.create!(name: "user2")

    User::DatabaseAuthentication.create!(
      user: user1,
      email: "user1@example.com",
      password: "password123"
    )
    User::DatabaseAuthentication.create!(
      user: user2,
      email: "user2@example.com",
      password: "password123"
    )

    result = User::DuplicateEmailChecker.duplicate?("notfound@example.com")

    assert_equal false, result
  end

  test "SnsCredentialに複数のレコードが存在しても、検索対象のメールアドレスが存在しない場合はfalseを返す" do
    user1 = User.create!(name: "user1")
    user2 = User.create!(name: "user2")

    User::SnsCredential.create!(
      user: user1,
      provider: "google_oauth2",
      uid: "111111",
      email: "user1@example.com"
    )
    User::SnsCredential.create!(
      user: user2,
      provider: "google_oauth2",
      uid: "222222",
      email: "user2@example.com"
    )

    result = User::DuplicateEmailChecker.duplicate?("notfound@example.com")

    assert_equal false, result
  end

  # =====================================
  # エッジケーステスト
  # =====================================

  test "特殊文字を含むメールアドレスでも正しくチェックできる" do
    user = User.create!(name: "special_user")
    email = "test+tag@example.com"
    User::DatabaseAuthentication.create!(
      user: user,
      email: email,
      password: "password123"
    )

    result = User::DuplicateEmailChecker.duplicate?(email)

    assert_equal true, result
  end
end
