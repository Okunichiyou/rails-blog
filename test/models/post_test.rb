require "test_helper"

class PostTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "post_test_author", author: true)
  end

  # =====================================
  # バリデーションテスト
  # =====================================

  test "titleが空の場合、無効であること" do
    now = Time.current
    post = Post.new(user: @user, title: "", first_published_at: now, last_published_at: now)
    assert_not post.valid?
    assert_includes post.errors[:title], "を入力してください"
  end

  test "titleが255文字を超える場合、無効であること" do
    now = Time.current
    post = Post.new(user: @user, title: "a" * 256, first_published_at: now, last_published_at: now)
    assert_not post.valid?
    assert_includes post.errors[:title], "は255文字以内で入力してください"
  end

  test "first_published_atが空の場合、無効であること" do
    post = Post.new(user: @user, title: "テスト記事", first_published_at: nil, last_published_at: Time.current)
    assert_not post.valid?
    assert_includes post.errors[:first_published_at], "を入力してください"
  end

  test "last_published_atが空の場合、無効であること" do
    post = Post.new(user: @user, title: "テスト記事", first_published_at: Time.current, last_published_at: nil)
    assert_not post.valid?
    assert_includes post.errors[:last_published_at], "を入力してください"
  end

  test "有効な属性を持つ場合、有効であること" do
    now = Time.current
    post = Post.new(user: @user, title: "テスト記事", first_published_at: now, last_published_at: now)
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
      assert_not_nil post.first_published_at
      assert_not_nil post.last_published_at
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

  test "update_from_draft!がfirst_published_atを変更しないこと" do
    draft = PostDraft.create!(user: @user, title: "タイトル")
    post = Post.create_from_draft!(draft)
    original_first_published_at = post.first_published_at

    travel 1.hour do
      draft.update!(title: "新タイトル")
      post.update_from_draft!(draft)
    end

    assert_equal original_first_published_at, post.first_published_at
  end

  test "update_from_draft!がlast_published_atを更新すること" do
    draft = PostDraft.create!(user: @user, title: "タイトル")
    post = Post.create_from_draft!(draft)
    original_last_published_at = post.last_published_at

    travel 1.hour do
      draft.update!(title: "新タイトル")
      post.update_from_draft!(draft)
      post.reload

      assert_not_equal original_last_published_at, post.last_published_at
    end
  end

  # =====================================
  # likes_countテスト
  # =====================================

  test "likes_countがいいね数を返すこと" do
    draft = PostDraft.create!(user: @user, title: "いいねテスト")
    post = Post.create_from_draft!(draft)
    user1 = User.create!(name: "likes_count_user1", author: false)
    user2 = User.create!(name: "likes_count_user2", author: false)

    assert_equal 0, post.likes_count

    PostLike.create!(user: user1, post: post)
    assert_equal 1, post.likes_count

    PostLike.create!(user: user2, post: post)
    assert_equal 2, post.likes_count
  end

  # =====================================
  # liked_by?テスト
  # =====================================

  test "liked_by?がユーザーがいいねしているかどうかを返すこと" do
    draft = PostDraft.create!(user: @user, title: "liked_by?テスト")
    post = Post.create_from_draft!(draft)
    user = User.create!(name: "liked_by_user", author: false)

    assert_not post.liked_by?(user)

    PostLike.create!(user: user, post: post)
    assert post.liked_by?(user)
  end

  test "liked_by?がnilの場合falseを返すこと" do
    draft = PostDraft.create!(user: @user, title: "liked_by?nilテスト")
    post = Post.create_from_draft!(draft)

    assert_not post.liked_by?(nil)
  end
end
