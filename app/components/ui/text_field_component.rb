module Ui
  class TextFieldComponent < ApplicationComponent
    SIZE_OPTIONS = %i[full large medium small].freeze
    VARIANT_OPTIONS = %i[default alert].freeze

    # @rbs (builder: ActionView::Helpers::FormBuilder, method: Symbol, size: Symbol, ?variant: Symbol, **untyped) -> void
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

    # @rbs (untyped) -> String
    def field_classes(extra_classes)
      classes = [
        "box-border border-[1.5px] rounded-sm px-2 py-1",
        "border-default",
        "text-size-body font-weight-body",
        "text-default",
        "placeholder:text-placeholder",
        "disabled:text-secondary disabled:cursor-not-allowed disabled:opacity-60",
        size_class,
        variant_class,
        extra_classes
      ].compact
      classes.join(" ")
    end

    # @rbs () -> String
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
      else
        ""
      end
    end

    # @rbs () -> String
    def variant_class
      return "" if @variant == :default

      case @variant
      when :alert
        "border-alert"
      else
        ""
      end
    end
  end
end
