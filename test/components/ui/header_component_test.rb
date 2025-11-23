require "test_helper"

class HeaderComponentTest < ViewComponent::TestCase
  # =====================================
  # 基本構造のテスト
  # =====================================
  test "基本的なヘッダー構造が正しくレンダリングされること" do
    render_inline(Ui::HeaderComponent.new(login_user: nil))

    # ヘッダー要素の確認
    assert_selector("header")

    # ロゴの確認
    assert_selector(".logo a[href='/']", text: "奥日曜のWebサイト")

    # テーマ切り替えボタンの確認
    assert_selector("#theme-toggle-button[data-controller='theme-toggle'][data-action='click->theme-toggle#toggle']")

    # ハンバーガーメニューボタンの確認
    assert_selector(".hamburger-menu-button[data-controller='hamburger-menu'][data-action='click->hamburger-menu#toggle']")

    # ハンバーガーメニューの確認
    assert_selector(".hamburger-menu")
  end

  # =====================================
  # 未ログイン状態のテスト
  # =====================================
  test "未ログイン時にログインリンクが表示されること" do
    render_inline(Ui::HeaderComponent.new(login_user: nil))

    # ログインリンクの確認
    assert_selector(".hamburger-menu a[href='/login']", text: "ログイン")

    # ログアウトリンクが表示されないことの確認
    assert_no_selector(".hamburger-menu a", text: "ログアウト")
  end

  # =====================================
  # ログイン状態のテスト
  # =====================================
  test "ログイン時にログアウトリンクが表示されること" do
    user = User.new(id: 1, name: "test")
    render_inline(Ui::HeaderComponent.new(login_user: user))

    # ログアウトリンクの確認
    assert_selector(".hamburger-menu a[href='/logout'][data-turbo-method='delete']", text: "ログアウト")

    # ログインリンクが表示されないことの確認
    assert_no_selector(".hamburger-menu a", text: "ログイン")
  end

  # =====================================
  # HTML属性のテスト
  # =====================================
  test "カスタムHTML属性が設定されること" do
    render_inline(Ui::HeaderComponent.new(login_user: nil, id: "custom-header", class: "custom-class"))

    assert_selector("header#custom-header.custom-class")
  end
end
