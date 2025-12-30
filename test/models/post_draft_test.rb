require "test_helper"

class PostDraftTest < ActiveSupport::TestCase
  # =====================================
  # データ作成処理 - 正常系
  # =====================================

  test "PostDraft単体で保存できる - titleを持っている" do
    user = User.create!(name: "test_author", author: true)
    draft = PostDraft.new(user: user, title: "テスト記事")
    assert draft.valid?
    assert draft.save
  end

  test "PostDraftにcontentを設定できる" do
    user = User.create!(name: "test_author2", author: true)
    draft = PostDraft.create!(user: user, title: "テスト記事")
    draft.content = "<p>本文です</p>"
    draft.save!

    assert_includes draft.content, "本文です"
  end

  test "new_draft?がpost_idがnilの場合trueを返す" do
    user = User.create!(name: "test_author3", author: true)
    draft = PostDraft.new(user: user, title: "新規記事")

    assert draft.new_draft?
  end

  # =====================================
  # データ作成処理 - 準正常系
  # =====================================

  test "titleが空の場合、バリデーションエラーになること" do
    user = User.create!(name: "test_author4", author: true)
    draft = PostDraft.new(user: user, title: "")

    assert_not draft.valid?
    assert_includes draft.errors[:title], "を入力してください"
  end

  test "titleが255文字を超える場合、バリデーションエラーになること" do
    user = User.create!(name: "test_author5", author: true)
    draft = PostDraft.new(user: user, title: "a" * 256)

    assert_not draft.valid?
    assert_includes draft.errors[:title], "は255文字以内で入力してください"
  end

  test "titleが255文字以内の場合、保存できること" do
    user = User.create!(name: "test_author6", author: true)
    draft = PostDraft.new(user: user, title: "a" * 255)

    assert draft.valid?
  end

  # =====================================
  # 関連テスト
  # =====================================

  test "ユーザーが削除された時に、関連するPostDraftも削除されること" do
    user = User.create!(name: "delete_test_author", author: true)
    PostDraft.create!(user: user, title: "削除テスト記事")

    assert_difference "PostDraft.count", -1 do
      user.destroy
    end
  end

  test "userは必須であること" do
    draft = PostDraft.new(title: "タイトル")

    assert_not draft.valid?
    assert_includes draft.errors[:user], "を入力してください"
  end
end
