require "test_helper"

class BaseTest < ViewComponent::TestCase
  # テスト用の継承クラス
  class TestComponent < ::Ui::Base
    def initialize
      @html_options = { class: [ "test" ] }
    end
  end

  class TestNoClassComponent < ::Ui::Base
    def initialize
      @html_options = {}
    end
  end

  # =====================================
  # #filter_attribute
  # =====================================
  test "ホワイトリストに含まれるvalueを渡された時、valueを返すこと" do
    white_list = %i[allow1 allow2]
    target = Ui::Base.new

    result = target.send(:filter_attribute, value: :allow1, white_list:)

    assert_equal :allow1, result
  end

  test "ホワイトリストに含まれないvalueを渡された時、ArgumentErrorを返すこと" do
    white_list = %i[allow1 allow2]
    target = Ui::Base.new

    error = assert_raises(ArgumentError) do
      target.send(:filter_attribute, value: :not_allowed, white_list:)
    end

    assert_equal "Invalid attribute value: 'not_allowed'. Must be one of allow1, allow2.", error.message
  end

  # =====================================
  # #before_render
  # =====================================
  test "継承先クラスでbefore_renderが正しいdata-scopeを設定すること" do
    target = TestComponent.new

    target.send(:before_render)

    html_options = target.instance_variable_get(:@html_options)
    assert_equal "base-test-test-component", html_options[:"data-scope"]
  end

  test "継承先クラスで独自のクラスが設定されている時、before_renderが正しいclassを追加すること" do
    target = TestComponent.new

    target.send(:before_render)

    html_options = target.instance_variable_get(:@html_options)
    assert_includes html_options[:class], "base-test-test-component"
  end

  test "継承先クラスで独自のクラスが設定されていない時、before_renderが正しいclassを追加すること" do
    target = TestNoClassComponent.new

    target.send(:before_render)

    html_options = target.instance_variable_get(:@html_options)
    assert_includes html_options[:class], "base-test-test-no-class-component"
  end
end
