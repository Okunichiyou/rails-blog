require "test_helper"

class DomainBaseTest < ViewComponent::TestCase
  # テスト用の継承クラス
  class TestComponent < ::Domain::Base
    def initialize
      @html_options = { class: [ "test" ] }
    end
  end

  class TestNoClassComponent < ::Domain::Base
    def initialize
      @html_options = {}
    end
  end

  # =====================================
  # #before_render
  # =====================================
  test "継承先クラスでbefore_renderが正しいdata-scopeを設定すること" do
    target = TestComponent.new

    target.send(:before_render)

    html_options = target.instance_variable_get(:@html_options)
    assert_equal "domain-base-test-test-component", html_options[:"data-scope"]
  end

  test "継承先クラスで独自のクラスが設定されている時、before_renderが正しいclassを追加すること" do
    target = TestComponent.new

    target.send(:before_render)

    html_options = target.instance_variable_get(:@html_options)
    assert_includes html_options[:class], "domain-base-test-test-component"
  end

  test "継承先クラスで独自のクラスが設定されていない時、before_renderが正しいclassを追加すること" do
    target = TestNoClassComponent.new

    target.send(:before_render)

    html_options = target.instance_variable_get(:@html_options)
    assert_includes html_options[:class], "domain-base-test-test-no-class-component"
  end

  test "@html_optionsがnilの時、before_renderが@html_optionsを初期化すること" do
    target = TestComponent.new
    target.instance_variable_set(:@html_options, nil)

    target.send(:before_render)

    html_options = target.instance_variable_get(:@html_options)
    assert_equal "domain-base-test-test-component", html_options[:"data-scope"]
  end
end
