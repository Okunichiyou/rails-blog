require "test_helper"

class Ui::Icon::PlusComponentTest < ViewComponent::TestCase
  test "デフォルトサイズ(md)でアイコンが生成されること" do
    render_inline(Ui::Icon::PlusComponent.new)

    assert_selector("svg.w-5.h-5")
  end

  test "size: smで小さいアイコンが生成されること" do
    render_inline(Ui::Icon::PlusComponent.new(size: :sm))

    assert_selector("svg.w-4.h-4")
  end

  test "size: lgで大きいアイコンが生成されること" do
    render_inline(Ui::Icon::PlusComponent.new(size: :lg))

    assert_selector("svg.w-6.h-6")
  end

  test "不適切なsizeを適用したらエラーが出ること" do
    assert_raises(ArgumentError, "Invalid attribute value: 'invalid'. Must be one of sm, md, lg.") do
      Ui::Icon::PlusComponent.new(size: :invalid)
    end
  end

  test "追加のクラスを渡せること" do
    render_inline(Ui::Icon::PlusComponent.new(class: "text-primary"))

    assert_selector("svg.w-5.h-5.text-primary")
  end
end
