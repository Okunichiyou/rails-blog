require "test_helper"

class PostPresenterTest < ActiveSupport::TestCase
  test "100文字以上の場合、末尾が「...」でtruncateされること" do
    content = "a" * 101
    result = PostPresenter.beginning_of_content(content: content)

    assert_equal 100, result.length
    assert_equal "a" * 97 + "...", result
  end

  test "100文字の場合、そのまま表示されること" do
    content = "a" * 100
    result = PostPresenter.beginning_of_content(content: content)

    assert_equal content, result
  end


  test "空文字を渡した場合、空文字が返ること" do
    result = PostPresenter.beginning_of_content(content: "")

    assert_equal "", result
  end

  test "HTMLタグが除去された状態で表示されること" do
    content = "<p>Hello</p><strong>World</strong>"
    result = PostPresenter.beginning_of_content(content: content)

    assert_equal "HelloWorld", result
  end
end
