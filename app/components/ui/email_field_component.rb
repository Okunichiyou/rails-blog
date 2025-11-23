module Ui
  class EmailFieldComponent < ApplicationComponent
    SIZE_OPTIONS = %i[full large medium small].freeze
    VARIANT_OPTIONS = %i[default alert].freeze

    def initialize(
      builder:,
      method:,
      size:,
      variant: :default,
      **html_options
    )
      @builder = builder
      @method = method
      @size = filter_attribute(value: size, white_list: SIZE_OPTIONS)
      @variant = filter_attribute(value: variant, white_list: VARIANT_OPTIONS)
      @html_options = html_options.merge(class: field_classes(html_options[:class]))
    end

    private

    def field_classes(extra_classes)
      classes = [
        "box-border border-[1.5px] rounded-[var(--radius-sm)] px-2 py-1",
        "border-[var(--color-border-default)]",
        "text-[length:var(--font-size-body)] font-[var(--font-weight-body)]",
        "text-[var(--color-text-default)]",
        "placeholder:text-[var(--color-text-placeholder)]",
        "disabled:text-[var(--color-text-secondary)] disabled:cursor-not-allowed disabled:opacity-60",
        size_class,
        variant_class,
        extra_classes
      ].compact
      classes.join(" ")
    end

    def size_class
      case @size
      when :full
        "w-full"
      when :large
        "w-[20rem]"
      when :medium
        "w-[15rem]"
      when :small
        "w-[10rem]"
      end
    end

    def variant_class
      return "" if @variant == :default

      case @variant
      when :alert
        "border-[var(--color-border-alert)]"
      end
    end
  end
end
