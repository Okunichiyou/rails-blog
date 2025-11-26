require "test_helper"

class ApplicationComponentTest < ViewComponent::TestCase
  # テスト用の継承クラス
  class TestComponent < ApplicationComponent
    # @rbs () -> void
    def initialize
    end
  end

  # =====================================
  # #filter_attribute
  # =====================================
  test "ホワイトリストに含まれるvalueを渡された時、valueを返すこと" do
    white_list = %i[allow1 allow2]
    target = TestComponent.new

    result = target.send(:filter_attribute, value: :allow1, white_list:)

    assert_equal :allow1, result
  end

  test "ホワイトリストに含まれないvalueを渡された時、ArgumentErrorを返すこと" do
    white_list = %i[allow1 allow2]
    target = TestComponent.new

    error = assert_raises(ArgumentError) do
      target.send(:filter_attribute, value: :not_allowed, white_list:)
    end

    assert_equal "Invalid attribute value: 'not_allowed'. Must be one of allow1, allow2.", error.message
  end
end
