require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author = User.create!(name: "posts_controller_author", author: true)
    @non_author = User.create!(name: "posts_non_author", author: false)

    User::DatabaseAuthentication.create!(
      user: @author,
      email: "posts_author@example.com",
      password: "password123"
    )
    User::DatabaseAuthentication.create!(
      user: @non_author,
      email: "posts_non_author@example.com",
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

  test "GET /posts 記事一覧を表示できる" do
    draft = PostDraft.create!(user: @author, title: "公開記事")
    Post.create_from_draft!(draft)

    get posts_path
    assert_response :success
    assert_select "h3", text: "公開記事"
  end

  test "GET /posts 未ログインでもアクセスできる" do
    get posts_path
    assert_response :success
  end

  test "GET /posts 記事が公開日時の降順で表示される" do
    draft1 = PostDraft.create!(user: @author, title: "古い記事")
    post1 = Post.create_from_draft!(draft1)
    post1.update!(published_at: 2.days.ago)

    draft2 = PostDraft.create!(user: @author, title: "新しい記事")
    Post.create_from_draft!(draft2)

    get posts_path
    assert_response :success

    # 新しい記事が先に表示される
    assert_match(/新しい記事.*古い記事/m, response.body)
  end

  # =====================================
  # show アクション
  # =====================================

  test "GET /posts/:id 記事詳細を表示できる" do
    draft = PostDraft.create!(user: @author, title: "詳細テスト")
    draft.update!(content: "記事の本文")
    published_post = Post.create_from_draft!(draft)

    get post_path(published_post)
    assert_response :success
    assert_select "h1", text: "詳細テスト"
  end

  test "GET /posts/:id 未ログインでもアクセスできる" do
    draft = PostDraft.create!(user: @author, title: "公開記事")
    published_post = Post.create_from_draft!(draft)

    get post_path(published_post)
    assert_response :success
  end

  test "GET /posts/:id 存在しない記事は404エラーになる" do
    get post_path(id: 99999)
    assert_response :not_found
  end

  # =====================================
  # 認証・認可テスト
  # =====================================

  test "POST /posts 未ログインの場合リダイレクト" do
    draft = PostDraft.create!(user: @author, title: "テスト")

    post posts_path, params: { draft_id: draft.id }
    assert_redirected_to root_path
  end

  test "POST /posts 著者でないユーザーの場合リダイレクト" do
    draft = PostDraft.create!(user: @non_author, title: "テスト")

    sign_in_as("posts_non_author@example.com")
    post posts_path, params: { draft_id: draft.id }
    assert_redirected_to root_path
  end

  # =====================================
  # create アクション
  # =====================================

  test "POST /posts 下書きを公開できる" do
    sign_in_as("posts_author@example.com")
    draft = PostDraft.create!(user: @author, title: "公開テスト")
    draft.content = "公開する本文"

    assert_difference "Post.count", 1 do
      post posts_path, params: { draft_id: draft.id }
    end

    assert_redirected_to post_drafts_path
    assert_equal "記事を公開しました", flash[:notice]

    draft.reload
    assert_not draft.new_draft?
  end

  test "POST /posts 既に公開済みの下書きは再公開できない" do
    sign_in_as("posts_author@example.com")
    draft = PostDraft.create!(user: @author, title: "既公開テスト")
    Post.create_from_draft!(draft)

    assert_no_difference "Post.count" do
      post posts_path, params: { draft_id: draft.id }
    end

    assert_redirected_to post_drafts_path
    assert_equal "この下書きは既に公開されています", flash[:alert]
  end

  # =====================================
  # update アクション
  # =====================================

  test "PATCH /posts/:id 公開記事を更新できる" do
    sign_in_as("posts_author@example.com")
    draft = PostDraft.create!(user: @author, title: "初期タイトル")
    draft.update!(content: "初期本文")
    published_post = Post.create_from_draft!(draft)

    draft.update!(title: "更新後タイトル", content: "更新後本文")

    patch post_path(published_post), params: { draft_id: draft.id }

    assert_redirected_to post_drafts_path
    assert_equal "記事を更新しました", flash[:notice]

    published_post.reload
    assert_equal "更新後タイトル", published_post.title
    assert_equal "更新後本文", published_post.content.to_plain_text
  end

  test "PATCH /posts/:id 紐づいていない下書きでは更新できない" do
    sign_in_as("posts_author@example.com")
    draft1 = PostDraft.create!(user: @author, title: "下書き1")
    draft2 = PostDraft.create!(user: @author, title: "下書き2")
    published_post = Post.create_from_draft!(draft1)

    patch post_path(published_post), params: { draft_id: draft2.id }

    assert_redirected_to post_drafts_path
    assert_equal "不正なリクエストです", flash[:alert]
  end

  # =====================================
  # セキュリティテスト
  # =====================================

  test "他ユーザーの下書きを公開しようとすると404エラーになる" do
    other_author = User.create!(name: "other_posts_author", author: true)
    other_draft = PostDraft.create!(user: other_author, title: "他人の下書き")

    sign_in_as("posts_author@example.com")

    post posts_path, params: { draft_id: other_draft.id }
    assert_response :not_found
  end

  test "他ユーザーの記事を更新しようとすると404エラーになる" do
    other_author = User.create!(name: "other_posts_author2", author: true)
    other_draft = PostDraft.create!(user: other_author, title: "他人の下書き")
    other_post = Post.create_from_draft!(other_draft)

    sign_in_as("posts_author@example.com")

    patch post_path(other_post), params: { draft_id: other_draft.id }
    assert_response :not_found
  end
end
