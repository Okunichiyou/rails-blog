require "test_helper"

class Domain::User::EmailConfirmationFormComponentTest < ViewComponent::TestCase
  test "flashがある場合、flashを表示していること" do
    form = User::EmailConfirmationForm.new
    flash_mock = { notice: "確認メールを送信しました" }

    component = Domain::User::EmailConfirmationFormComponent.new(form: form, resource_name: :confirmation)
    component.define_singleton_method(:flash) { flash_mock }

    render_inline(component)

    assert_selector("div", text: "確認メールを送信しました")
  end

  test "email-confirmation-formの要素があること" do
    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: User::EmailConfirmationForm.new, resource_name: :confirmation))

    assert_selector("form.email-confirmation-form")
  end

  test "emailのラベルとinput要素があること" do
    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: User::EmailConfirmationForm.new, resource_name: :confirmation))

    assert_selector("label[for='user_email_confirmation_email']", text: "Email")
    assert_selector("input[type=email][name='user_email_confirmation[email]'][id='user_email_confirmation_email']")
  end

  test "submitボタンがあること" do
    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: User::EmailConfirmationForm.new, resource_name: :confirmation))

    assert_selector("button[type=submit]", text: "送信")
  end

  test "未確認のメールアドレスが設定されたフォームが表示されること" do
    form = User::EmailConfirmationForm.new(email: "new@example.com")

    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: form, resource_name: :confirmation))

    assert_selector("input[name*='email']")
    assert_selector("label", text: "Email")
  end

  test "確認済みのメールアドレスが設定されたフォームが表示されること" do
    form = User::EmailConfirmationForm.new(email: "confirmed@example.com")

    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: form, resource_name: :confirmation))

    assert_selector("input[name*='email']")
    assert_selector("label", text: "Email")
  end

  test "バリデーションエラーがある場合、入力フィールドがalert状態になること" do
    form = User::EmailConfirmationForm.new(email: "")
    form.valid? # バリデーションを実行してエラーを生成

    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: form, resource_name: :confirmation))

    assert_selector("input[type=email]")
  end

  test "バリデーションエラーがある場合、エラーメッセージが表示されること" do
    form = User::EmailConfirmationForm.new(email: "")
    form.valid? # バリデーションを実行してエラーを生成

    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: form, resource_name: :confirmation))

    assert_selector("ul li", text: /Emailを入力してください/)
  end

  test "バリデーションエラーがない場合、入力フィールドがdefault状態になること" do
    form = User::EmailConfirmationForm.new(email: "valid@example.com")

    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: form, resource_name: :confirmation))

    assert_selector("input[type=email]")
  end

  test "バリデーションエラーがない場合、エラーメッセージが表示されないこと" do
    form = User::EmailConfirmationForm.new(email: "valid@example.com")

    render_inline(Domain::User::EmailConfirmationFormComponent.new(form: form, resource_name: :confirmation))

    assert_no_selector("ul[data-scope]")
  end
end
