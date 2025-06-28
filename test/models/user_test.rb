require "test_helper"

class UserTest < ActiveSupport::TestCase
  # =====================================
  # データ作成処理 - 正常系
  # =====================================

  test "User単体で保存できる - nameを持っている" do
    user = User.new(name: "test_user")
    assert user.valid?
    assert user.save
  end

  test "User単体で保存できる - timestampを持っている" do
    user = User.create!(name: "timestamp_user")
    assert_not_nil user.created_at
    assert_not_nil user.updated_at
  end

  test "UserとDatabaseAuthenticationを組み合わせて保存できる" do
    user = User.new(name: "combined_user")
    user.build_database_authentication(
      email: "combined@example.com",
      password: "password123"
    )

    assert user.valid?
    assert user.database_authentication.valid?
    assert user.save
  end

  test "user.database_authenticationで関連したデータを取り出せる" do
    user = User.create!(name: "relation_user")
    auth = user.build_database_authentication(
      email: "relation@example.com",
      password: "password123"
    )
    auth.save!

    assert_equal user, auth.user
    assert_equal auth, user.database_authentication
  end

  test "nameが255文字で保存できる" do
    user = User.new(name: "a" * 255)
    assert user.valid?
    assert user.save
  end

  test "ASCII文字のnameで正常に保存できる" do
    original_name = "ASCII_user123"
    user = User.new(name: original_name)

    user.save!

    saved_user = User.find(user.id)
    assert_equal original_name, saved_user.name
  end

  test "日本語文字のnameで正常に保存できる" do
    original_name = "ユーザー太郎"
    user = User.new(name: original_name)

    user.save!

    saved_user = User.find(user.id)
    assert_equal original_name, saved_user.name
  end

  test "記号を含むnameで正常に保存できる" do
    original_name = "user-name_123.test"
    user = User.new(name: original_name)

    user.save!

    saved_user = User.find(user.id)
    assert_equal original_name, saved_user.name
  end

  test "4バイト文字のnameで正常に保存できる" do
    original_name = "絵文字🎉ユーザー"
    user = User.new(name: original_name)

    user.save!

    saved_user = User.find(user.id)
    assert_equal original_name, saved_user.name
  end

  test "空白スペースはトリミングされた状態になっていること" do
    user = User.new(name: "  trimmed_user  ")
    user.valid?
    assert_equal "trimmed_user", user.name
  end

  # =====================================
  # データ作成処理 - 準正常系(バリデーションエラー)
  # =====================================

  test "nameが256文字の場合、バリデーションエラーになること" do
    user = User.new(name: "a" * 256)
    assert_not user.valid?
    assert_includes user.errors[:name], "is too long (maximum is 255 characters)"
  end

  test "nameが重複している場合、バリデーションエラーになること" do
    User.create!(name: "duplicate_user")
    user = User.new(name: "duplicate_user")
    assert_not user.valid?
    assert_includes user.errors[:name], "has already been taken"
  end

  test "nameがnilの場合、バリデーションエラーになること" do
    user = User.new(name: nil)
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "nameが空文字の場合、バリデーションエラーになること" do
    user = User.new(name: "")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "nameが空白のみの場合、バリデーションエラーになること" do
    user = User.new(name: "   ")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "大文字小文字を区別せずに重複チェックすること" do
    User.create!(name: "CaseTest")
    user = User.new(name: "casetest")
    assert_not user.valid?
    assert_includes user.errors[:name], "has already been taken"
  end

  # =====================================
  # データ削除処理
  # =====================================

  test "ユーザーが削除された時に、関連するDatabaseAuthenticationも削除されること" do
    user = User.create!(name: "delete_user")
    auth = User::DatabaseAuthentication.create!(
      user: user,
      email: "delete@example.com",
      password: "password123"
    )

    user_id = user.id
    auth_id = auth.id

    assert_difference "User::DatabaseAuthentication.count", -1 do
      user.destroy
    end

    assert_nil User.find_by(id: user_id)
    assert_nil User::DatabaseAuthentication.find_by(id: auth_id)
  end

  # =====================================
  # Devise機能テスト
  # =====================================
  test "authenticatableモジュールが含まれていること" do
    assert User.devise_modules.include?(:authenticatable)
  end

  # =====================================
  # データベース制約テスト
  # =====================================

  test "データベースレベルでname一意性制約が働くこと" do
    User.create!(name: "unique_user")

    assert_raises ActiveRecord::RecordNotUnique do
      User.connection.execute(
        "INSERT INTO users (name, created_at, updated_at) VALUES ('unique_user', datetime('now'), datetime('now'))"
      )
    end
  end

  test "データベースレベルでnameのNOT NULL制約が働くこと" do
    assert_raises ActiveRecord::NotNullViolation do
      User.connection.execute(
        "INSERT INTO users (name, created_at, updated_at) VALUES (NULL, datetime('now'), datetime('now'))"
      )
    end
  end
end
