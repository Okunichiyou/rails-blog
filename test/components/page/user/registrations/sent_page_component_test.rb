require "test_helper"

class Page::User::Registrations::SentPageComponentTest < ViewComponent::TestCase
  test "確認メール送信完了のタイトルが表示されること" do
    render_inline(Page::User::Registrations::SentPageComponent.new)

    assert_selector("h2", text: "確認メールを送信しました")
  end

  test "PanelComponentが使用されていること" do
    render_inline(Page::User::Registrations::SentPageComponent.new)

    assert_selector(".ui-panel-component")
  end

  test "確認メール送信の説明文が表示されること" do
    render_inline(Page::User::Registrations::SentPageComponent.new)

    assert_selector("p", text: /ご入力いただいたメールアドレスに確認メールを送信しました/)
    assert_selector("p", text: /メールが届かない場合は、迷惑メールフォルダもご確認ください/)
  end

  test "別のメールアドレスで再送信リンクが表示されること" do
    render_inline(Page::User::Registrations::SentPageComponent.new)

    assert_selector("a[href='/registrations/confirmation/new']", text: "別のメールアドレスで再送信")
  end
end
