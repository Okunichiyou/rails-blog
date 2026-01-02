require "test_helper"

class PostLikeTest < ActiveSupport::TestCase
  setup do
    @author = User.create!(name: "post_like_test_author", author: true)
    @user = User.create!(name: "post_like_test_user", author: false)
    @draft = PostDraft.create!(user: @author, title: "いいねテスト記事")
    @post = Post.create_from_draft!(@draft)
  end

  # =====================================
  # バリデーションテスト
  # =====================================

  test "有効な属性を持つ場合、有効であること" do
    post_like = PostLike.new(user: @user, post: @post)
    assert post_like.valid?
  end

  test "同じユーザーが同じ投稿に複数回いいねできないこと" do
    PostLike.create!(user: @user, post: @post)
    duplicate_like = PostLike.new(user: @user, post: @post)
    assert_not duplicate_like.valid?
    assert_includes duplicate_like.errors[:user_id], "はすでに存在します"
  end

  test "異なるユーザーが同じ投稿にいいねできること" do
    other_user = User.create!(name: "other_like_user", author: false)
    PostLike.create!(user: @user, post: @post)
    other_like = PostLike.new(user: other_user, post: @post)
    assert other_like.valid?
  end

  test "同じユーザーが異なる投稿にいいねできること" do
    other_draft = PostDraft.create!(user: @author, title: "別の記事")
    other_post = Post.create_from_draft!(other_draft)

    PostLike.create!(user: @user, post: @post)
    other_like = PostLike.new(user: @user, post: other_post)
    assert other_like.valid?
  end

  # =====================================
  # アソシエーションテスト
  # =====================================

  test "ユーザーがliked_postsを取得できること" do
    PostLike.create!(user: @user, post: @post)
    assert_includes @user.liked_posts, @post
  end

  test "投稿がliked_by_usersを取得できること" do
    PostLike.create!(user: @user, post: @post)
    assert_includes @post.liked_by_users, @user
  end

  test "ユーザー削除時にいいねも削除されること" do
    PostLike.create!(user: @user, post: @post)

    assert_difference "PostLike.count", -1 do
      @user.destroy
    end
  end

  test "投稿削除時にいいねも削除されること" do
    PostLike.create!(user: @user, post: @post)

    assert_difference "PostLike.count", -1 do
      @post.destroy
    end
  end
end
