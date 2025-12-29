require "test_helper"

class Ui::RichTextAreaComponentTest < ViewComponent::TestCase
  # =====================================
  # バリデーションテスト
  # =====================================

  MockBuilder = Struct.new(:object_name)

  test "不正なsizeを指定した場合、ArgumentErrorが発生すること" do
    mock_builder = MockBuilder.new("post_draft")

    assert_raises ArgumentError do
      Ui::RichTextAreaComponent.new(
        builder: mock_builder,
        method: :content,
        size: :invalid,
        variant: :default
      )
    end
  end

  test "不正なvariantを指定した場合、ArgumentErrorが発生すること" do
    mock_builder = MockBuilder.new("post_draft")

    assert_raises ArgumentError do
      Ui::RichTextAreaComponent.new(
        builder: mock_builder,
        method: :content,
        size: :large,
        variant: :invalid
      )
    end
  end

  test "有効なsizeとvariantを指定した場合、エラーが発生しないこと" do
    mock_builder = MockBuilder.new("post_draft")

    component = Ui::RichTextAreaComponent.new(
      builder: mock_builder,
      method: :content,
      size: :large,
      variant: :default
    )

    assert_not_nil component
  end

  test "size: :fullの場合、適切なクラスが設定されること" do
    mock_builder = MockBuilder.new("post_draft")

    component = Ui::RichTextAreaComponent.new(
      builder: mock_builder,
      method: :content,
      size: :full,
      variant: :default
    )

    assert_not_nil component
  end
end
