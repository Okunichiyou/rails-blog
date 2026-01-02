require "test_helper"

class Domain::Post::LikeButtonComponentTest < ViewComponent::TestCase
  setup do
    @author = User.create!(name: "like_btn_test_author", author: true)
    @user = User.create!(name: "like_btn_test_user", author: false)
    @draft = PostDraft.create!(user: @author, title: "いいねボタンテスト記事")
    @post = Post.create_from_draft!(@draft)
  end

  # =====================================
  # 未ログイン状態のテスト
  # =====================================

  test "未ログイン時にログインページへのリンクが表示されること" do
    render_inline(Domain::Post::LikeButtonComponent.new(post: @post, current_user: nil))

    assert_selector("a[href='/login']")
  end

  test "未ログイン時にいいね数が表示されること" do
    PostLike.create!(user: @user, post: @post)
    render_inline(Domain::Post::LikeButtonComponent.new(post: @post, current_user: nil))

    assert_selector("span", text: "1")
  end

  # =====================================
  # ログイン状態・未いいねのテスト
  # =====================================

  test "未いいね時にいいねボタン（枠線）が表示されること" do
    render_inline(Domain::Post::LikeButtonComponent.new(post: @post, current_user: @user))

    assert_selector("form[action='/posts/#{@post.id}/like'][method='post']")
    assert_selector("button[type='submit']")
  end

  test "未いいね時にいいね数が0と表示されること" do
    render_inline(Domain::Post::LikeButtonComponent.new(post: @post, current_user: @user))

    assert_selector("span", text: "0")
  end

  # =====================================
  # ログイン状態・いいね済みのテスト
  # =====================================

  test "いいね済み時に解除ボタン（塗りつぶし）が表示されること" do
    PostLike.create!(user: @user, post: @post)
    render_inline(Domain::Post::LikeButtonComponent.new(post: @post, current_user: @user))

    # DELETEメソッドのフォーム
    assert_selector("form[action='/posts/#{@post.id}/like']")
    assert_selector("input[name='_method'][value='delete']", visible: :hidden)
  end

  test "いいね済み時にいいね数が1と表示されること" do
    PostLike.create!(user: @user, post: @post)
    render_inline(Domain::Post::LikeButtonComponent.new(post: @post, current_user: @user))

    assert_selector("span", text: "1")
  end

  # =====================================
  # いいね数のテスト
  # =====================================

  test "複数のいいねがカウントされること" do
    user2 = User.create!(name: "like_btn_test_user2", author: false)
    user3 = User.create!(name: "like_btn_test_user3", author: false)

    PostLike.create!(user: @user, post: @post)
    PostLike.create!(user: user2, post: @post)
    PostLike.create!(user: user3, post: @post)

    render_inline(Domain::Post::LikeButtonComponent.new(post: @post, current_user: nil))

    assert_selector("span", text: "3")
  end
end
