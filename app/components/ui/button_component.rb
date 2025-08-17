module Ui
  class ButtonComponent < Ui::Base
    CATEGORY_OPTIONS = %i[primary secondary].freeze
    SIZE_OPTIONS = %i[full large medium small].freeze
    TYPE_OPTIONS = %i[button submit reset].freeze
    VARIANT_OPTIONS = %i[default danger].freeze

    def initialize(
      category:,
      button_class: "",
      size:,
      type: :button,
      variant: :default,
      text:,
      html_options: {}
    )
      @category = filter_attribute(value: category, white_list: CATEGORY_OPTIONS)
      @button_class = button_class.split
      @size = filter_attribute(value: size, white_list: SIZE_OPTIONS)
      @type = filter_attribute(value: type, white_list: TYPE_OPTIONS)
      @variant = filter_attribute(value: variant, white_list: VARIANT_OPTIONS)
      @text = text
      @html_options = build_html_options(html_options)
    end

    private

    def build_html_options(html_options)
      options = html_options.merge({ class: button_classes })
      options.merge!({ type: @type.to_s })
    end

    def button_classes
      classes = []
      classes.push(@category.to_s)
      classes.concat(@button_class)
      classes.push(@size.to_s)
      classes.push(@variant.to_s)
    end
  end
end
