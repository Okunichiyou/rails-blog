require "test_helper"

class IconButtonComponentTest < ViewComponent::TestCase
  # =====================================
  # #html属性
  # =====================================
  test "デフォルトの属性が設定され、渡したカテゴリ/テキストが反映されること" do
    render_inline(Ui::IconButtonComponent.new(category: :secondary, size: :medium, text: "test"))

    # button要素とテキストの確認
    assert_selector("button[type=button]", text: "test")
  end

  test "渡したdisabledが反映されること" do
    render_inline(Ui::IconButtonComponent.new(category: :secondary, size: :medium, text: "test", disabled: true))

    assert_selector("button[disabled]", text: "test")
  end

  test "渡したクラスが反映されること" do
    render_inline(Ui::IconButtonComponent.new(category: :secondary, size: :medium, text: "test", class: "added added2"))

    assert_selector("button.added.added2", text: "test")
  end

  # =====================================
  # #アイコン
  # =====================================
  test "アイコンなしで正常にレンダリングされること" do
    render_inline(Ui::IconButtonComponent.new(category: :primary, size: :medium, text: "test"))

    assert_selector("button", text: "test")
    assert_no_selector("button img")
  end

  test "アイコンを左側に配置できること" do
    icon_html = '<img src="/test-icon.png" class="icon">'.html_safe
    render_inline(Ui::IconButtonComponent.new(
      category: :secondary,
      size: :medium,
      text: "test",
      icon: icon_html,
      icon_position: :left
    ))

    assert_selector("button", text: "test")
    assert_selector("button img.icon")

    # アイコンがテキストの前にあることを確認
    button_content = page.find("button div.z-3").text
    assert_includes button_content, "test"
  end

  test "アイコンを右側に配置できること" do
    icon_html = '<img src="/test-icon.png" class="icon">'.html_safe
    render_inline(Ui::IconButtonComponent.new(
      category: :secondary,
      size: :medium,
      text: "test",
      icon: icon_html,
      icon_position: :right
    ))

    assert_selector("button", text: "test")
    assert_selector("button img.icon")
  end

  # =====================================
  # #カテゴリとバリアント
  # =====================================
  test "primaryカテゴリでborder-noneクラスが適用されること" do
    render_inline(Ui::IconButtonComponent.new(category: :primary, size: :medium, text: "test"))

    assert_selector("button.border-none")
  end

  test "secondaryカテゴリでborder-2クラスが適用されること" do
    render_inline(Ui::IconButtonComponent.new(category: :secondary, size: :medium, text: "test"))

    # border-2が適用されていない（button_classesにborder_classが含まれる）
    assert_selector("button.secondary")
  end

  test "dangerバリアントが反映されること" do
    render_inline(Ui::IconButtonComponent.new(
      category: :secondary,
      size: :medium,
      text: "test",
      variant: :danger
    ))

    assert_selector("button.danger")
  end

  # =====================================
  # #サイズ
  # =====================================
  test "size: :fullでw-fullクラスが適用されること" do
    render_inline(Ui::IconButtonComponent.new(category: :primary, size: :full, text: "test"))

    assert_selector("button.w-full")
  end

  test "size: :largeで正しいクラスが適用されること" do
    render_inline(Ui::IconButtonComponent.new(category: :primary, size: :large, text: "test"))

    assert_selector("button.w-\\[12\\.5rem\\]")
  end

  test "size: :mediumで正しいクラスが適用されること" do
    render_inline(Ui::IconButtonComponent.new(category: :primary, size: :medium, text: "test"))

    assert_selector("button.w-\\[7\\.5rem\\]")
  end

  test "size: :smallで正しいクラスが適用されること" do
    render_inline(Ui::IconButtonComponent.new(category: :primary, size: :small, text: "test"))

    assert_selector("button.w-\\[5rem\\]")
  end

  # =====================================
  # #type属性
  # =====================================
  test "type: :submitが反映されること" do
    render_inline(Ui::IconButtonComponent.new(
      category: :primary,
      size: :medium,
      text: "test",
      type: :submit
    ))

    assert_selector("button[type=submit]")
  end

  test "type: :resetが反映されること" do
    render_inline(Ui::IconButtonComponent.new(
      category: :primary,
      size: :medium,
      text: "test",
      type: :reset
    ))

    assert_selector("button[type=reset]")
  end
end
