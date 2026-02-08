require "test_helper"

class DeviseSessionsNewViewTest < ActionView::TestCase
  def setup
    @resource = User::DatabaseAuthentication.new
    @resource_name = :user_database_authentication
  end

  # Deviseのヘルパーメソッドをビューコンテキストに追加
  def view
    super.tap do |v|
      v.define_singleton_method(:resource) { @resource }
      v.define_singleton_method(:resource_name) { @resource_name }
    end
  end

  test "flashがある場合、flashを表示していること" do
    flash[:notice] = "ログインしてください"

    render template: "devise/sessions/new"

    assert_select("div", text: "ログインしてください")
  end

  test "auth_enabledがfalseの場合、登録機能の注釈を表示すること" do
    with_auth_disabled do
      render template: "devise/sessions/new"

      assert_select("p", text: "現在、ユーザー登録機能は提供されていません")
    end
  end

  test "auth_enabledがtrueの場合、登録機能の注釈を表示しないこと" do
    with_auth_enabled do
      render template: "devise/sessions/new"

      assert_select("p", text: "現在、ユーザー登録機能は提供されていません", count: 0)
    end
  end

  private

  def with_auth_disabled
    original = Rails.configuration.auth_enabled
    Rails.configuration.auth_enabled = false
    yield
  ensure
    Rails.configuration.auth_enabled = original
  end

  def with_auth_enabled
    original = Rails.configuration.auth_enabled
    Rails.configuration.auth_enabled = true
    yield
  ensure
    Rails.configuration.auth_enabled = original
  end
end
