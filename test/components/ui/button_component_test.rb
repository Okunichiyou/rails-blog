require "test_helper"

class ButtonComponentTest < ViewComponent::TestCase
  # =====================================
  # #html属性
  # =====================================
  test "デフォルトの属性が設定され、渡したカテゴリ/テキストが反映されること" do
    render_inline(Ui::ButtonComponent.new(category: :secondary, size: :medium, text: "test"))

    # button要素とクラスの確認
    assert_selector("button.ui-button-component.secondary.medium.default[data-scope=ui-button-component]")

    # glass effectの要素がui-button-component直下にあることを確認
    assert_selector(".ui-button-component > .glass-effect")
    assert_selector(".ui-button-component > .glass-tint")
    assert_selector(".ui-button-component > .glass-shine")
    assert_selector(".ui-button-component > .glass-text", text: "test")
  end

  test "渡したdisabledが反映されること" do
    render_inline(Ui::ButtonComponent.new(category: :secondary, size: :medium, text: "test", html_options: { disabled: true }))

    assert_selector("button.ui-button-component.secondary.medium.default[data-scope=ui-button-component][disabled]")
  end

  test "渡したクラスが反映されること" do
    render_inline(Ui::ButtonComponent.new(category: :secondary, size: :medium, text: "test", button_class: "added added2"))

    assert_selector("button.ui-button-component.secondary.medium.default.added.added2[data-scope=ui-button-component]")
  end
end
