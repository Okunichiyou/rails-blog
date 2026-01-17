require "test_helper"

class Users::PostDraftsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author = User.create!(name: "controller_test_author", author: true)
    @non_author = User.create!(name: "non_author_user", author: false)

    User::DatabaseAuthentication.create!(
      user: @author,
      email: "author@example.com",
      password: "password123"
    )
    User::DatabaseAuthentication.create!(
      user: @non_author,
      email: "non_author@example.com",
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
  # 認証・認可テスト
  # =====================================

  test "GET /post_drafts 未ログインの場合リダイレクト" do
    get users_post_drafts_path
    assert_redirected_to root_path
  end

  test "GET /post_drafts 著者でないユーザーの場合リダイレクト" do
    sign_in_as("non_author@example.com")
    get users_post_drafts_path
    assert_redirected_to root_path
  end

  test "GET /post_drafts 著者ユーザーの場合成功" do
    sign_in_as("author@example.com")
    get users_post_drafts_path
    assert_response :success
  end

  # =====================================
  # index アクション
  # =====================================

  test "GET /post_drafts 自分の下書きのみ表示される" do
    sign_in_as("author@example.com")

    PostDraft.create!(user: @author, title: "自分の下書き")
    other_author = User.create!(name: "other_author", author: true)
    PostDraft.create!(user: other_author, title: "他人の下書き")

    get users_post_drafts_path
    assert_response :success
    assert_select "h3", text: "自分の下書き"
    assert_select "h3", text: "他人の下書き", count: 0
  end

  # =====================================
  # new/create アクション
  # =====================================

  test "GET /post_drafts/new 新規作成フォーム表示" do
    sign_in_as("author@example.com")
    get new_users_post_draft_path
    assert_response :success
    assert_select "form", count: 1
  end

  test "POST /post_drafts 正常な下書き作成" do
    sign_in_as("author@example.com")

    assert_difference "PostDraft.count", 1 do
      post users_post_drafts_path, params: {
        post_draft: {
          title: "新規下書き",
          content: "<p>本文</p>"
        }
      }
    end

    assert_redirected_to users_post_drafts_path
    assert_equal "下書きを保存しました", flash[:notice]
  end

  test "POST /post_drafts 不正な入力でエラー" do
    sign_in_as("author@example.com")

    assert_no_difference "PostDraft.count" do
      post users_post_drafts_path, params: {
        post_draft: {
          title: "",
          content: "<p>本文</p>"
        }
      }
    end

    assert_response :unprocessable_content
  end

  # =====================================
  # edit/update アクション
  # =====================================

  test "GET /post_drafts/:id/edit 編集フォーム表示" do
    sign_in_as("author@example.com")
    draft = PostDraft.create!(user: @author, title: "編集テスト")

    get edit_users_post_draft_path(draft)
    assert_response :success
  end

  test "PATCH /post_drafts/:id 正常な更新" do
    sign_in_as("author@example.com")
    draft = PostDraft.create!(user: @author, title: "更新前")

    patch users_post_draft_path(draft), params: {
      post_draft: {
        title: "更新後",
        content: "<p>更新本文</p>"
      }
    }

    assert_redirected_to users_post_drafts_path
    draft.reload
    assert_equal "更新後", draft.title
  end

  test "PATCH /post_drafts/:id 不正な入力でエラー" do
    sign_in_as("author@example.com")
    draft = PostDraft.create!(user: @author, title: "更新前")

    patch users_post_draft_path(draft), params: {
      post_draft: {
        title: "",
        content: "<p>本文</p>"
      }
    }

    assert_response :unprocessable_content
    draft.reload
    assert_equal "更新前", draft.title
  end

  # =====================================
  # destroy アクション
  # =====================================

  test "DELETE /post_drafts/:id 下書き削除" do
    sign_in_as("author@example.com")
    draft = PostDraft.create!(user: @author, title: "削除テスト")

    assert_difference "PostDraft.count", -1 do
      delete users_post_draft_path(draft)
    end

    assert_redirected_to users_post_drafts_path
  end

  # =====================================
  # セキュリティテスト
  # =====================================

  test "他ユーザーの下書きの編集画面にアクセスすると404エラーになる" do
    other_author = User.create!(name: "other_author2", author: true)
    other_draft = PostDraft.create!(user: other_author, title: "他人の下書き")

    sign_in_as("author@example.com")

    get edit_users_post_draft_path(other_draft)
    assert_response :not_found
  end

  test "GET /post_drafts/:id/edit 存在しない下書きIDの場合404エラーになる" do
    sign_in_as("author@example.com")

    get edit_users_post_draft_path(id: 0)
    assert_response :not_found
  end

  test "PATCH /post_drafts/:id 存在しない下書きIDの場合404エラーになる" do
    sign_in_as("author@example.com")

    patch users_post_draft_path(id: 0), params: {
      post_draft: {
        title: "更新テスト",
        content: "<p>本文</p>"
      }
    }
    assert_response :not_found
  end

  test "DELETE /post_drafts/:id 存在しない下書きIDの場合404エラーになる" do
    sign_in_as("author@example.com")

    delete users_post_draft_path(id: 0)
    assert_response :not_found
  end
end
