require "test_helper"

class Domain::PostDraft::FormComponentTest < ViewComponent::TestCase
  setup do
    @user = User.create!(name: "component_test_author", author: true)
    @form = PostDraftForm.new(user: @user)
  end

  # =====================================
  # 基本レンダリングテスト
  # =====================================

  test "フォーム要素があること" do
    render_inline(Domain::PostDraft::FormComponent.new(
      form: @form,
      url: "/post_drafts"
    ))

    assert_selector("form[action='/post_drafts']")
  end

  test "titleのラベルとinput要素があること" do
    render_inline(Domain::PostDraft::FormComponent.new(
      form: @form,
      url: "/post_drafts"
    ))

    assert_selector("label[for='post_draft_title']")
    assert_selector("input[type='text'][name='post_draft[title]']")
  end

  test "contentのラベルとTiptapエディタ要素があること" do
    render_inline(Domain::PostDraft::FormComponent.new(
      form: @form,
      url: "/post_drafts"
    ))

    assert_selector("label[for='post_draft_content']")
    assert_selector("[data-controller='tiptap']")
    assert_selector("[data-tiptap-target='editor']")
  end

  test "submitボタンがあること" do
    render_inline(Domain::PostDraft::FormComponent.new(
      form: @form,
      url: "/post_drafts"
    ))

    assert_selector("button[type='submit']", text: "保存")
  end

  # =====================================
  # HTTPメソッドテスト
  # =====================================

  test "デフォルトでPOSTメソッドが設定されること" do
    render_inline(Domain::PostDraft::FormComponent.new(
      form: @form,
      url: "/post_drafts"
    ))

    assert_selector("form[method='post']")
  end

  test "編集モードの場合PATCHメソッドが設定されること" do
    render_inline(Domain::PostDraft::FormComponent.new(
      form: @form,
      url: "/post_drafts/1",
      method: :patch
    ))

    assert_selector("input[name='_method'][value='patch']", visible: :hidden)
  end

  # =====================================
  # エラー表示テスト
  # =====================================

  test "バリデーションエラーがある場合、エラーメッセージが表示されること" do
    @form.title = ""
    @form.save # バリデーションをトリガー

    render_inline(Domain::PostDraft::FormComponent.new(
      form: @form,
      url: "/post_drafts"
    ))

    assert_selector("li", text: "を入力してください")
  end
end
