require "test_helper"

class Users::LikedPostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author = User.create!(name: "liked_posts_test_author", author: true)
    @user = User.create!(name: "liked_posts_test_user", author: false)

    User::DatabaseAuthentication.create!(
      user: @user,
      email: "liked_posts_test_user@example.com",
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
  # index アクション
  # =====================================

  test "GET /users/liked_posts いいねした投稿一覧を表示できる" do
    PostLike.create!(user: @user, post: @post)
    sign_in_as("liked_posts_test_user@example.com")

    get users_liked_posts_path
    assert_response :success
    assert_select "h3", text: "いいねテスト記事"
  end

  test "GET /users/liked_posts いいねした投稿がない場合はメッセージを表示" do
    sign_in_as("liked_posts_test_user@example.com")

    get users_liked_posts_path
    assert_response :success
    assert_select "p", text: "いいねした投稿はありません"
  end

  test "GET /users/liked_posts 未ログイン時はログインページにリダイレクト" do
    get users_liked_posts_path
    assert_redirected_to login_path
    assert_equal "ログインしてください", flash[:alert]
  end

  test "GET /users/liked_posts いいねした投稿が新しい順に表示される" do
    draft2 = PostDraft.create!(user: @author, title: "2番目にいいねした記事")
    post2 = Post.create_from_draft!(draft2)

    PostLike.create!(user: @user, post: @post, created_at: 2.days.ago)
    PostLike.create!(user: @user, post: post2, created_at: 1.day.ago)

    sign_in_as("liked_posts_test_user@example.com")
    get users_liked_posts_path
    assert_response :success

    # 新しくいいねした記事が先に表示される
    assert_match(/2番目にいいねした記事.*いいねテスト記事/m, response.body)
  end

  test "GET /users/liked_posts 他のユーザーがいいねした投稿は表示されない" do
    other_user = User.create!(name: "other_liked_posts_user", author: false)
    PostLike.create!(user: other_user, post: @post)

    sign_in_as("liked_posts_test_user@example.com")
    get users_liked_posts_path
    assert_response :success
    assert_select "p", text: "いいねした投稿はありません"
  end
end
