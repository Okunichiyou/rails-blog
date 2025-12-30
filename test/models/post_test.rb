require "test_helper"

class PostTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "post_test_author", author: true)
  end

  # =====================================
  # バリデーションテスト
  # =====================================

  test "titleが空の場合、無効であること" do
    post = Post.new(user: @user, title: "", published_at: Time.current)
    assert_not post.valid?
    assert_includes post.errors[:title], "を入力してください"
  end

  test "titleが255文字を超える場合、無効であること" do
    post = Post.new(user: @user, title: "a" * 256, published_at: Time.current)
    assert_not post.valid?
    assert_includes post.errors[:title], "は255文字以内で入力してください"
  end

  test "published_atが空の場合、無効であること" do
    post = Post.new(user: @user, title: "テスト記事", published_at: nil)
    assert_not post.valid?
    assert_includes post.errors[:published_at], "を入力してください"
  end

  test "有効な属性を持つ場合、有効であること" do
    post = Post.new(user: @user, title: "テスト記事", published_at: Time.current)
    assert post.valid?
  end

  # =====================================
  # create_from_draft!テスト
  # =====================================

  test "create_from_draft!が下書きからPostを作成すること" do
    draft = PostDraft.create!(user: @user, title: "下書きタイトル")
    draft.content = "下書き本文"

    assert_difference "Post.count", 1 do
      post = Post.create_from_draft!(draft)

      assert_equal @user, post.user
      assert_equal "下書きタイトル", post.title
      assert_equal "下書き本文", post.content
      assert_not_nil post.published_at
    end

    draft.reload
    assert_not_nil draft.post_id
    assert_not draft.new_draft?
  end

  test "create_from_draft!が下書きとPostを関連付けること" do
    draft = PostDraft.create!(user: @user, title: "関連付けテスト")

    post = Post.create_from_draft!(draft)

    assert_equal post, draft.reload.post
    assert_equal draft, post.draft
  end

  # =====================================
  # update_from_draft!テスト
  # =====================================

  test "update_from_draft!が下書きからPostを更新すること" do
    draft = PostDraft.create!(user: @user, title: "初期タイトル")
    draft.content = "初期本文"
    post = Post.create_from_draft!(draft)

    draft.update!(title: "更新タイトル")
    draft.content = "更新本文"

    post.update_from_draft!(draft)

    assert_equal "更新タイトル", post.title
    assert_equal "更新本文", post.content
  end

  test "update_from_draft!がpublished_atを変更しないこと" do
    draft = PostDraft.create!(user: @user, title: "タイトル")
    post = Post.create_from_draft!(draft)
    original_published_at = post.published_at

    travel 1.hour do
      draft.update!(title: "新タイトル")
      post.update_from_draft!(draft)
    end

    assert_equal original_published_at, post.published_at
  end
end
