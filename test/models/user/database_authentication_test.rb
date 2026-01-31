require "test_helper"

class User::DatabaseAuthenticationTest < ActiveSupport::TestCase
  # =====================================
  # データ作成処理 - 正常系
  # =====================================

  test "有効な属性でDatabaseAuthenticationを作成できる" do
    user = User.create!(name: "test_user")
    auth = User::DatabaseAuthentication.new(
      user: user,
      email: "test@example.com",
      password: "password123"
    )

    assert auth.valid?
    assert auth.save
  end

  test "UserとDatabaseAuthenticationの関連が正常に動作する" do
    user = User.create!(name: "relation_user")

    auth = user.build_database_authentication(
      email: "relation@example.com",
      password: "password123"
    )
    auth.save!

    assert_equal user, auth.user
    assert_equal auth, user.database_authentication
  end

  test "パスワードが暗号化されて保存される" do
    user = User.create!(name: "encrypt_user")
    plain_password = "password123"

    auth = User::DatabaseAuthentication.create!(
      user: user,
      email: "encrypt@example.com",
      password: plain_password
    )

    assert_not_equal plain_password, auth.encrypted_password
    assert auth.encrypted_password.present?
    assert auth.valid_password?(plain_password)
  end

  # =====================================
  # データ作成処理 - 準正常系(バリデーションエラー)
  # =====================================

  test "emailが空の場合、バリデーションエラーになる" do
    user = User.create!(name: "test_user")
    auth = User::DatabaseAuthentication.new(
      user: user,
      email: "",
      password: "password123"
    )

    assert_not auth.valid?
    assert_includes auth.errors[:email], "を入力してください"
  end

  test "emailがnilの場合、バリデーションエラーになる" do
    user = User.create!(name: "test_user")
    auth = User::DatabaseAuthentication.new(
      user: user,
      email: nil,
      password: "password123"
    )

    assert_not auth.valid?
    assert_includes auth.errors[:email], "を入力してください"
  end

  test "emailが無効な形式の場合、バリデーションエラーになる" do
    user = User.create!(name: "test_user")
    invalid_emails = [ "invalid", "test@", "@example.com", "test with space@example.com" ]

    invalid_emails.each do |invalid_email|
      auth = User::DatabaseAuthentication.new(
        user: user,
        email: invalid_email,
        password: "password123"
      )

      assert_not auth.valid?, "#{invalid_email} should be invalid"
      assert_includes auth.errors[:email], "は不正な値です"
    end
  end

  test "emailが重複している場合、バリデーションエラーになる" do
    user1 = User.create!(name: "user1")
    user2 = User.create!(name: "user2")
    User::DatabaseAuthentication.create!(
      user: user1,
      email: "duplicate@example.com",
      password: "password123"
    )

    auth2 = User::DatabaseAuthentication.new(
      user: user2,
      email: "duplicate@example.com",
      password: "password456"
    )

    assert_not auth2.valid?
    assert_includes auth2.errors[:email], "はすでに存在します"
  end

  test "emailの大文字小文字を区別せずに重複チェックする" do
    user1 = User.create!(name: "user1")
    user2 = User.create!(name: "user2")
    User::DatabaseAuthentication.create!(
      user: user1,
      email: "Case@Example.Com",
      password: "password123"
    )

    auth2 = User::DatabaseAuthentication.new(
      user: user2,
      email: "case@example.com",
      password: "password456"
    )

    assert_not auth2.valid?
    assert_includes auth2.errors[:email], "はすでに存在します"
  end

  test "passwordが空の場合、バリデーションエラーになる" do
    user = User.create!(name: "test_user")
    auth = User::DatabaseAuthentication.new(
      user: user,
      email: "test@example.com",
      password: ""
    )

    assert_not auth.valid?
    assert_includes auth.errors[:password], "を入力してください"
  end

  test "passwordが短すぎる場合、バリデーションエラーになる" do
    user = User.create!(name: "test_user")
    auth = User::DatabaseAuthentication.new(
      user: user,
      email: "test@example.com",
      password: "12345"
    )

    assert_not auth.valid?
    assert_includes auth.errors[:password], "は6文字以上で入力してください"
  end

  test "passwordが長すぎる場合、バリデーションエラーになる" do
    user = User.create!(name: "test_user")
    auth = User::DatabaseAuthentication.new(
      user: user,
      email: "test@example.com",
      password: "a" * 129
    )

    assert_not auth.valid?
    assert_includes auth.errors[:password], "は128文字以内で入力してください"
  end

  test "userが存在しない場合、バリデーションエラーになる" do
    auth = User::DatabaseAuthentication.new(
      user: nil,
      email: "test@example.com",
      password: "password123"
    )

    assert_not auth.valid?
    assert_includes auth.errors[:user], "を入力してください"
  end

  # =====================================
  # パスワード境界値テスト
  # =====================================

  test "passwordが6文字で正常に保存できる" do
    user = User.create!(name: "test_user")
    auth = User::DatabaseAuthentication.new(
      user: user,
      email: "test@example.com",
      password: "123456"
    )

    assert auth.valid?
    assert auth.save
  end

  test "passwordが128文字で正常に保存できる" do
    user = User.create!(name: "test_user")
    auth = User::DatabaseAuthentication.new(
      user: user,
      email: "test@example.com",
      password: "a" * 128
    )

    assert auth.valid?
    assert auth.save
  end

  # =====================================
  # 認証機能テスト
  # =====================================

  test "正しいパスワードで認証が成功する" do
    user = User.create!(name: "auth_user")
    password = "correct_password"
    auth = User::DatabaseAuthentication.create!(
      user: user,
      email: "auth@example.com",
      password: password
    )

    assert auth.valid_password?(password)
  end

  test "間違ったパスワードで認証が失敗する" do
    user = User.create!(name: "auth_user")
    auth = User::DatabaseAuthentication.create!(
      user: user,
      email: "auth@example.com",
      password: "correct_password"
    )

    assert_not auth.valid_password?("wrong_password")
  end

  test "空のパスワードで認証が失敗する" do
    user = User.create!(name: "auth_user")
    auth = User::DatabaseAuthentication.create!(
      user: user,
      email: "auth@example.com",
      password: "correct_password"
    )

    assert_not auth.valid_password?("")
    assert_not auth.valid_password?(nil)
  end

  # =====================================
  # Deviseモジュールテスト
  # =====================================

  test "database_authenticatableモジュールが含まれている" do
    assert User::DatabaseAuthentication.devise_modules.include?(:database_authenticatable)
  end

  test "validatableモジュールが含まれている" do
    assert User::DatabaseAuthentication.devise_modules.include?(:validatable)
  end

  test "lockableモジュールが含まれている" do
    assert User::DatabaseAuthentication.devise_modules.include?(:lockable)
  end

  # =====================================
  # データベース制約テスト
  # =====================================

  test "データベースレベルでemail一意性制約が働く" do
    user1 = User.create!(name: "user1")
    user2 = User.create!(name: "user2")
    User::DatabaseAuthentication.create!(
      user: user1,
      email: "unique@example.com",
      password: "password123"
    )

    assert_raises ActiveRecord::RecordNotUnique do
      User::DatabaseAuthentication.connection.execute(
        "INSERT INTO user_database_authentications (user_id, email, encrypted_password, created_at, updated_at) VALUES (#{user2.id}, 'unique@example.com', 'dummy', datetime('now'), datetime('now'))"
      )
    end
  end

  test "データベースレベルでuser_idのNOT NULL制約が働く" do
    assert_raises ActiveRecord::NotNullViolation do
      User::DatabaseAuthentication.connection.execute(
        "INSERT INTO user_database_authentications (user_id, email, encrypted_password, created_at, updated_at) VALUES (NULL, 'test@example.com', 'dummy', datetime('now'), datetime('now'))"
      )
    end
  end

  test "データベースレベルでemailのNOT NULL制約が働く" do
    user = User.create!(name: "test_user")

    assert_raises ActiveRecord::NotNullViolation do
      User::DatabaseAuthentication.connection.execute(
        "INSERT INTO user_database_authentications (user_id, email, encrypted_password, created_at, updated_at) VALUES (#{user.id}, NULL, 'dummy', datetime('now'), datetime('now'))"
      )
    end
  end

  # =====================================
  # セキュリティテスト
  # =====================================

  test "パスワードが平文で保存されない" do
    user = User.create!(name: "security_user")
    plain_password = "secret_password"

    auth = User::DatabaseAuthentication.create!(
      user: user,
      email: "security@example.com",
      password: plain_password
    )

    assert_not_equal plain_password, auth.encrypted_password
    assert_not auth.encrypted_password.include?(plain_password)
  end

  test "同じパスワードでも異なるハッシュが生成される" do
    user1 = User.create!(name: "user1")
    user2 = User.create!(name: "user2")
    same_password = "same_password"

    auth1 = User::DatabaseAuthentication.create!(
      user: user1,
      email: "user1@example.com",
      password: same_password
    )
    auth2 = User::DatabaseAuthentication.create!(
      user: user2,
      email: "user2@example.com",
      password: same_password
    )

    assert_not_equal auth1.encrypted_password, auth2.encrypted_password
  end

  test "bcryptアルゴリズムでパスワードが暗号化される" do
    user = User.create!(name: "bcrypt_user")

    auth = User::DatabaseAuthentication.create!(
      user: user,
      email: "bcrypt@example.com",
      password: "test_password"
    )

    assert auth.encrypted_password.start_with?("$2a$")
  end

  # =====================================
  # アソシエーションテスト
  # =====================================

  test "userが削除されるとdatabase_authenticationも削除される" do
    user = User.create!(name: "cascade_user")
    auth = User::DatabaseAuthentication.create!(
      user: user,
      email: "cascade@example.com",
      password: "password123"
    )
    auth_id = auth.id

    user.destroy

    assert_nil User::DatabaseAuthentication.find_by(id: auth_id)
  end

  test "database_authenticationが削除されてもuserは削除されない" do
    user = User.create!(name: "no_cascade_user")
    auth = User::DatabaseAuthentication.create!(
      user: user,
      email: "no_cascade@example.com",
      password: "password123"
    )
    user_id = user.id

    auth.destroy

    assert User.find_by(id: user_id)
  end

  # =====================================
  # タイムスタンプテスト
  # =====================================

  test "作成時にタイムスタンプが設定される" do
    user = User.create!(name: "timestamp_user")

    auth = User::DatabaseAuthentication.create!(
      user: user,
      email: "timestamp@example.com",
      password: "password123"
    )

    assert_not_nil auth.created_at
    assert_not_nil auth.updated_at
  end

  test "更新時にupdated_atが更新される" do
    user = User.create!(name: "update_user")
    auth = User::DatabaseAuthentication.create!(
      user: user,
      email: "update@example.com",
      password: "password123"
    )
    original_updated_at = auth.updated_at

    sleep 0.01
    auth.update!(email: "updated@example.com")

    assert auth.updated_at > original_updated_at
  end
end
