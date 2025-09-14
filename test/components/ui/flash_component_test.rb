require "test_helper"

class Ui::FlashComponentTest < ViewComponent::TestCase
  test "ui-flash-componentの要素があること" do
    render_inline(Ui::FlashComponent.new(flash_type: :notice))

    assert_selector("div.ui-flash-component[data-scope='ui-flash-component']")
  end

  test "flash_typeのクラスが設定できること" do
    render_inline(Ui::FlashComponent.new(flash_type: :alert))

    assert_selector("div.ui-flash-component.alert")
  end

  test "任意のクラスが設定できること" do
    render_inline(Ui::FlashComponent.new(flash_type: :notice, html_options: { class: "custom-class another-class" }))

    assert_selector("div.ui-flash-component.notice.custom-class.another-class")
  end

  test "不適切なflash_typeを適用したらエラーが出ること" do
    assert_raises(ArgumentError, "Invalid attribute value: 'invalid'. Must be one of info, notice, warn, alert.") do
      Ui::FlashComponent.new(flash_type: :invalid)
    end
  end

  test "全てのflash_typeオプションが適用されること" do
    %i[info notice warn alert].each do |flash_type|
      render_inline(Ui::FlashComponent.new(flash_type: flash_type))

      assert_selector("div.ui-flash-component.#{flash_type}")
    end
  end

  test "slotで内容を定義できること" do
    render_inline(Ui::FlashComponent.new(flash_type: :notice)) do |component|
      component.with_flash_content do
        "Flash Message Content"
      end
    end

    assert_selector("div.ui-flash-component", text: "Flash Message Content")
  end

  test "html_optionsが空でもエラーが出ないこと" do
    assert_nothing_raised do
      render_inline(Ui::FlashComponent.new(flash_type: :notice, html_options: {}))
    end

    assert_selector("div.ui-flash-component.notice")
  end
end
