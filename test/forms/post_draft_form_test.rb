require "test_helper"

class PostDraftFormTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "form_test_author", author: true)
  end

  # =====================================
  # 新規作成 - 正常系
  # =====================================

  test "正常な入力でPostDraftが保存される" do
    form = PostDraftForm.new(
      user: @user,
      title: "テスト記事",
      content: "<p>本文</p>"
    )

    assert_difference "PostDraft.count", 1 do
      assert form.save
    end

    draft = PostDraft.last
    assert_equal "テスト記事", draft.title
    assert_equal @user, draft.user
  end

  test "contentが空でも保存できる" do
    form = PostDraftForm.new(
      user: @user,
      title: "タイトルのみ",
      content: ""
    )

    assert_difference "PostDraft.count", 1 do
      assert form.save
    end
  end

  # =====================================
  # 新規作成 - 準正常系
  # =====================================

  test "titleが空の場合、保存に失敗する" do
    form = PostDraftForm.new(
      user: @user,
      title: "",
      content: "<p>本文</p>"
    )

    assert_no_difference "PostDraft.count" do
      assert_not form.save
    end

    assert form.errors[:title].any?
  end

  # =====================================
  # 更新 - 正常系
  # =====================================

  test "既存のPostDraftを更新できる" do
    draft = PostDraft.create!(user: @user, title: "元のタイトル")

    form = PostDraftForm.new(
      user: @user,
      post_draft: draft,
      title: "新しいタイトル",
      content: "<p>新しい本文</p>"
    )

    assert_no_difference "PostDraft.count" do
      assert form.save
    end

    draft.reload
    assert_equal "新しいタイトル", draft.title
  end

  test "保存後にpost_draftにアクセスできる" do
    form = PostDraftForm.new(
      user: @user,
      title: "テスト",
      content: ""
    )

    form.save

    assert_not_nil form.post_draft
    assert_equal "テスト", form.post_draft.title
  end
end
