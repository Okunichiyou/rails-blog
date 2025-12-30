require "test_helper"

class Ui::TiptapEditorComponentTest < ViewComponent::TestCase
  # @rbs () -> ActionView::Helpers::FormBuilder
  def form_builder_with_content(content: nil)
    user = User.new(name: "test_user", author: true)
    form = PostDraftForm.new(user: user, title: "テスト", content: content)
    ActionView::Helpers::FormBuilder.new("post_draft", form, vc_test_controller.view_context, {})
  end

  test "基本的な TiptapEditor が生成されること" do
    render_inline(Ui::TiptapEditorComponent.new(builder: form_builder_with_content, method: :content))

    assert_selector("[data-controller='tiptap']")
    assert_selector("[data-tiptap-target='editor']")
    assert_selector("input[type='hidden'][name='post_draft[content]'][data-tiptap-target='input']", visible: :all)
  end

  test "hidden inputにvalue属性として初期値が設定されること" do
    render_inline(Ui::TiptapEditorComponent.new(
      builder: form_builder_with_content(content: "<p>既存のコンテンツ</p>"),
      method: :content
    ))

    assert_selector("input[type='hidden'][value='<p>既存のコンテンツ</p>']", visible: :all)
  end

  test "contentがnilの場合でもvalue属性が空文字で設定されること" do
    render_inline(Ui::TiptapEditorComponent.new(
      builder: form_builder_with_content(content: nil),
      method: :content
    ))

    assert_selector("input[type='hidden'][value='']", visible: :all)
  end

  test "data-tiptap-content-value属性にもコンテンツが設定されること" do
    render_inline(Ui::TiptapEditorComponent.new(
      builder: form_builder_with_content(content: "<p>テスト内容</p>"),
      method: :content
    ))

    assert_selector("[data-tiptap-content-value='<p>テスト内容</p>']")
  end

  test "不適切なvariantを適用したらエラーが出ること" do
    assert_raises(ArgumentError, "Invalid attribute value: 'invalid'. Must be one of default, alert.") do
      Ui::TiptapEditorComponent.new(builder: form_builder_with_content, method: :content, variant: :invalid)
    end
  end

  test "variantがalertの場合にalertクラスが適用されること" do
    render_inline(Ui::TiptapEditorComponent.new(
      builder: form_builder_with_content,
      method: :content,
      variant: :alert
    ))

    assert_selector(".border-alert")
  end
end
