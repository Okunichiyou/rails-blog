require "test_helper"

class Users::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author = User.create!(name: "users_posts_author", author: true)
    @non_author = User.create!(name: "users_posts_non_author", author: false)

    User::DatabaseAuthentication.create!(
      user: @author,
      email: "users_posts_author@example.com",
      password: "password123"
    )
    User::DatabaseAuthentication.create!(
      user: @non_author,
      email: "users_posts_non_author@example.com",
      password: "password123"
    )
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

  test "GET /users/:user_id/posts ユーザーの投稿記事一覧を表示できる" do
    draft = PostDraft.create!(user: @author, title: "投稿記事")
    Post.create_from_draft!(draft)

    get user_posts_path(@author)
    assert_response :success
    assert_select "h3", text: "投稿記事"
  end

  test "GET /users/:user_id/posts 未ログインでもアクセスできる" do
    get user_posts_path(@author)
    assert_response :success
  end

  test "GET /users/:user_id/posts 存在しないユーザーの場合404を返す" do
    get user_posts_path(user_id: 0)
    assert_response :not_found
  end

  test "GET /users/:user_id/posts 他のauthorの記事一覧も閲覧できる" do
    other_author = User.create!(name: "other_users_posts_author", author: true)
    other_draft = PostDraft.create!(user: other_author, title: "他人の記事")
    Post.create_from_draft!(other_draft)

    sign_in_as("users_posts_author@example.com")
    get user_posts_path(other_author)
    assert_response :success
    assert_select "h3", text: "他人の記事"
  end

  test "GET /users/:user_id/posts 自分の記事一覧では削除ボタンが表示される" do
    sign_in_as("users_posts_author@example.com")
    draft = PostDraft.create!(user: @author, title: "自分の記事")
    Post.create_from_draft!(draft)

    get user_posts_path(@author)
    assert_response :success
    assert_select "button", text: "削除"
  end

  test "GET /users/:user_id/posts 他人の記事一覧では削除ボタンが表示されない" do
    other_author = User.create!(name: "other_users_posts_author2", author: true)
    other_draft = PostDraft.create!(user: other_author, title: "他人の記事")
    Post.create_from_draft!(other_draft)

    sign_in_as("users_posts_author@example.com")
    get user_posts_path(other_author)
    assert_response :success
    assert_select "button", text: "削除", count: 0
  end

  # =====================================
  # edit アクション
  # =====================================

  test "GET /users/:user_id/posts/:id/edit 紐づく下書きがある場合、下書き編集画面にリダイレクトする" do
    sign_in_as("users_posts_author@example.com")
    draft = PostDraft.create!(user: @author, title: "編集テスト")
    published_post = Post.create_from_draft!(draft)

    get edit_user_post_path(@author, published_post)
    assert_redirected_to edit_users_post_draft_path(draft)
  end

  test "GET /users/:user_id/posts/:id/edit 紐づく下書きがない場合、新しい下書きを作成してリダイレクトする" do
    sign_in_as("users_posts_author@example.com")
    draft = PostDraft.create!(user: @author, title: "編集テスト", content: "<p>本文</p>")
    published_post = Post.create_from_draft!(draft)
    draft.destroy!

    assert_difference "PostDraft.count", 1 do
      get edit_user_post_path(@author, published_post)
    end

    new_draft = PostDraft.last
    assert_equal published_post.id, new_draft.post_id
    assert_equal published_post.title, new_draft.title
    assert_equal published_post.content, new_draft.content
    assert_redirected_to edit_users_post_draft_path(new_draft)
  end

  test "GET /users/:user_id/posts/:id/edit 未ログインの場合リダイレクト" do
    draft = PostDraft.create!(user: @author, title: "テスト")
    published_post = Post.create_from_draft!(draft)

    get edit_user_post_path(@author, published_post)
    assert_redirected_to root_path
  end

  test "GET /users/:user_id/posts/:id/edit 他人の記事を編集しようとするとリダイレクト" do
    other_author = User.create!(name: "other_users_posts_edit_author", author: true)
    other_draft = PostDraft.create!(user: other_author, title: "他人の記事")
    other_post = Post.create_from_draft!(other_draft)

    sign_in_as("users_posts_author@example.com")
    get edit_user_post_path(other_author, other_post)
    assert_redirected_to root_path
  end

  # =====================================
  # destroy アクション
  # =====================================

  test "DELETE /users/:user_id/posts/:id 公開記事を削除できる" do
    sign_in_as("users_posts_author@example.com")
    draft = PostDraft.create!(user: @author, title: "削除テスト")
    published_post = Post.create_from_draft!(draft)

    assert_difference "Post.count", -1 do
      delete user_post_path(@author, published_post)
    end

    assert_redirected_to user_posts_path(@author)
    assert_equal "記事を削除しました", flash[:notice]
  end

  test "DELETE /users/:user_id/posts/:id 削除後、関連する下書きのpost_idがNULLになる" do
    sign_in_as("users_posts_author@example.com")
    draft = PostDraft.create!(user: @author, title: "削除テスト")
    published_post = Post.create_from_draft!(draft)

    delete user_post_path(@author, published_post)

    draft.reload
    assert_nil draft.post_id
    assert draft.new_draft?
  end

  test "DELETE /users/:user_id/posts/:id 未ログインの場合リダイレクト" do
    draft = PostDraft.create!(user: @author, title: "テスト")
    published_post = Post.create_from_draft!(draft)

    delete user_post_path(@author, published_post)
    assert_redirected_to root_path
  end

  test "DELETE /users/:user_id/posts/:id 他のユーザーの記事を削除しようとするとリダイレクト" do
    other_author = User.create!(name: "other_users_posts_author3", author: true)
    other_draft = PostDraft.create!(user: other_author, title: "他人の記事")
    other_post = Post.create_from_draft!(other_draft)

    sign_in_as("users_posts_author@example.com")

    assert_no_difference "Post.count" do
      delete user_post_path(other_author, other_post)
    end
    assert_redirected_to root_path
  end

  test "DELETE /users/:user_id/posts/:id 存在しない記事IDの場合404エラーになる" do
    sign_in_as("users_posts_author@example.com")

    delete user_post_path(@author, id: 0)
    assert_response :not_found
  end
end
