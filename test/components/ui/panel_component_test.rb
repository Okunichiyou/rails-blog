require "test_helper"

class Ui::PanelComponentTest < ViewComponent::TestCase
  test "panelの要素があること" do
    render_inline(Ui::PanelComponent.new(size: :medium))

    assert_selector("div")
  end

  test "任意のクラスが設定できること" do
    render_inline(Ui::PanelComponent.new(size: :medium, class: "custom-class another-class"))

    assert_selector("div.custom-class.another-class")
  end

  test "不適切なsizeのクラスを適用したらエラーが出ること" do
    assert_raises(ArgumentError, "Invalid attribute value: 'invalid'. Must be one of full, large, medium, small.") do
      Ui::PanelComponent.new(size: :invalid)
    end
  end

  test "slotで内容を定義できること" do
    render_inline(Ui::PanelComponent.new(size: :medium)) do |component|
      component.with_panel_content do
        "Test Content"
      end
    end

    assert_selector("div", text: "Test Content")
  end
end
