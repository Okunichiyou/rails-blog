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
end
