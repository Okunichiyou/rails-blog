require "test_helper"

class Posts::LikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author = User.create!(name: "likes_test_author", author: true)
    @user = User.create!(name: "likes_test_user", author: false)

    User::DatabaseAuthentication.create!(
      user: @user,
      email: "likes_test_user@example.com",
      password: "password123"
    )

    @draft = PostDraft.create!(user: @author, title: "いいねテスト記事")
    @post = Post.create_from_draft!(@draft)
  end

  def sign_in_as(email)
    post login_path, params: {
      database_authentication: {
        email: email,
        password: "password123"
      }
    }
  end

  # =====================================
  # create アクション
  # =====================================

  test "POST /posts/:post_id/like ログインユーザーがいいねできる" do
    sign_in_as("likes_test_user@example.com")

    assert_difference "PostLike.count", 1 do
      post post_like_path(@post)
    end

    assert_redirected_to post_path(@post)
    assert @post.post_likes.exists?(user: @user)
  end

  test "POST /posts/:post_id/like 同じ投稿に複数回いいねしてもエラーにならない" do
    sign_in_as("likes_test_user@example.com")
    PostLike.create!(user: @user, post: @post)

    assert_no_difference "PostLike.count" do
      post post_like_path(@post)
    end

    assert_redirected_to post_path(@post)
  end

  test "POST /posts/:post_id/like 未ログイン時はログインページにリダイレクト" do
    assert_no_difference "PostLike.count" do
      post post_like_path(@post)
    end

    assert_redirected_to login_path
    assert_equal "ログインしてください", flash[:alert]
  end

  test "POST /posts/:post_id/like 存在しない投稿の場合は404エラー" do
    sign_in_as("likes_test_user@example.com")

    post post_like_path(post_id: 0)
    assert_response :not_found
  end

  # =====================================
  # destroy アクション
  # =====================================

  test "DELETE /posts/:post_id/like ログインユーザーがいいねを解除できる" do
    sign_in_as("likes_test_user@example.com")
    PostLike.create!(user: @user, post: @post)

    assert_difference "PostLike.count", -1 do
      delete post_like_path(@post)
    end

    assert_redirected_to post_path(@post)
    assert_not @post.post_likes.exists?(user: @user)
  end

  test "DELETE /posts/:post_id/like いいねしていない投稿の解除はエラーにならない" do
    sign_in_as("likes_test_user@example.com")

    assert_no_difference "PostLike.count" do
      delete post_like_path(@post)
    end

    assert_redirected_to post_path(@post)
  end

  test "DELETE /posts/:post_id/like 未ログイン時はログインページにリダイレクト" do
    PostLike.create!(user: @user, post: @post)

    assert_no_difference "PostLike.count" do
      delete post_like_path(@post)
    end

    assert_redirected_to login_path
    assert_equal "ログインしてください", flash[:alert]
  end

  test "DELETE /posts/:post_id/like 存在しない投稿の場合は404エラー" do
    sign_in_as("likes_test_user@example.com")

    delete post_like_path(post_id: 0)
    assert_response :not_found
  end
end
