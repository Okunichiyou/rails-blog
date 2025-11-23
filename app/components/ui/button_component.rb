module Ui
  class ButtonComponent < ApplicationComponent
    CATEGORY_OPTIONS = %i[primary secondary].freeze
    SIZE_OPTIONS = %i[full large medium small].freeze
    TYPE_OPTIONS = %i[button submit reset].freeze
    VARIANT_OPTIONS = %i[default danger].freeze

    def initialize(
      category:,
      size:,
      type: :button,
      variant: :default,
      text:,
      **html_options
    )
      @category = filter_attribute(value: category, white_list: CATEGORY_OPTIONS)
      @size = filter_attribute(value: size, white_list: SIZE_OPTIONS)
      @type = filter_attribute(value: type, white_list: TYPE_OPTIONS)
      @variant = filter_attribute(value: variant, white_list: VARIANT_OPTIONS)
      @text = text
      @html_options = html_options.merge(type: @type.to_s, class: button_classes(html_options[:class]))
    end

    private

    def button_classes(extra_classes)
      classes = [
        "group",
        "border-none cursor-pointer font-bold px-10 py-6 text-center",
        "overflow-hidden relative transition-all duration-[400ms] ease-[cubic-bezier(0.175,0.885,0.32,2.2)]",
        "hover:px-[2.8rem] hover:py-[1.8rem]",
        "active:px-[3.1rem] active:py-[2.1rem]",
        "disabled:cursor-not-allowed disabled:opacity-50",
        "disabled:hover:px-10 disabled:hover:py-6",
        "rounded-[3rem]",
        @category,
        @variant == :danger ? "danger" : nil,
        size_class,
        extra_classes
      ].compact
      classes.join(" ")
    end

    def size_class
      case @size
      when :full
        "w-full"
      when :large
        "w-[12.5rem]"
      when :medium
        "w-[7.5rem]"
      when :small
        "w-[5rem]"
      end
    end

    def text_color_class
      case @category
      when :primary
        if @variant == :danger
          "text-btn-primary-danger"
        else
          "text-btn-primary"
        end
      when :secondary
        if @variant == :danger
          "text-btn-secondary-danger"
        else
          "text-btn-secondary"
        end
      end
    end

    def tint_bg_class
      case @category
      when :primary
        if @variant == :danger
          "bg-btn-primary-danger"
        else
          "bg-btn-primary"
        end
      when :secondary
        if @variant == :danger
          "bg-btn-secondary-danger"
        else
          "bg-btn-secondary"
        end
      end
    end
  end
end
