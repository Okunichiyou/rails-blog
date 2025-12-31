require "test_helper"

class Ui::Button::ComponentTest < ViewComponent::TestCase
  # =====================================
  # #html属性
  # =====================================
  test "デフォルトの属性が設定され、渡したカテゴリ/テキストが反映されること" do
    render_inline(Ui::Button::Component.new(category: :secondary, size: :medium, text: "test"))

    # button要素とテキストの確認
    assert_selector("button[type=button]", text: "test")
  end

  test "渡したdisabledが反映されること" do
    render_inline(Ui::Button::Component.new(category: :secondary, size: :medium, text: "test", disabled: true))

    assert_selector("button[disabled]", text: "test")
  end

  test "渡したクラスが反映されること" do
    render_inline(Ui::Button::Component.new(category: :secondary, size: :medium, text: "test", class: "added added2"))

    assert_selector("button.added.added2", text: "test")
  end

  # =====================================
  # カテゴリバリエーション
  # =====================================

  test "category: primaryでprimaryクラスが適用されること" do
    render_inline(Ui::Button::Component.new(category: :primary, size: :medium, text: "test"))
    assert_selector("button.primary")
  end

  # =====================================
  # サイズバリエーション
  # =====================================

  test "size: fullでw-fullクラスが適用されること" do
    render_inline(Ui::Button::Component.new(category: :secondary, size: :full, text: "test"))
    assert_selector("button.w-full")
  end

  test "size: largeでw-[12.5rem]クラスが適用されること" do
    render_inline(Ui::Button::Component.new(category: :secondary, size: :large, text: "test"))
    assert_selector('button.w-\[12\.5rem\]')
  end

  test "size: smallでw-[5rem]クラスが適用されること" do
    render_inline(Ui::Button::Component.new(category: :secondary, size: :small, text: "test"))
    assert_selector('button.w-\[5rem\]')
  end

  # =====================================
  # バリアントバリエーション
  # =====================================

  test "variant: dangerでdangerクラスが適用されること" do
    render_inline(Ui::Button::Component.new(category: :secondary, size: :medium, text: "test", variant: :danger))
    assert_selector("button.danger")
  end

  test "category: primary, variant: dangerの組み合わせ" do
    render_inline(Ui::Button::Component.new(category: :primary, size: :medium, text: "test", variant: :danger))
    assert_selector("button.primary.danger")
  end

  # =====================================
  # タイプバリエーション
  # =====================================

  test "type: submitでtype属性がsubmitになること" do
    render_inline(Ui::Button::Component.new(category: :secondary, size: :medium, text: "test", type: :submit))
    assert_selector("button[type='submit']")
  end

  test "type: resetでtype属性がresetになること" do
    render_inline(Ui::Button::Component.new(category: :secondary, size: :medium, text: "test", type: :reset))
    assert_selector("button[type='reset']")
  end
end
