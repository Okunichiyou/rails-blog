module Ui
  class RichTextAreaComponent < ApplicationComponent
    SIZE_OPTIONS = %i[full large medium].freeze
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
        "trix-content",
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
        "w-full min-h-[20rem]"
      when :large
        "w-full min-h-[15rem]"
      when :medium
        "w-full min-h-[10rem]"
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
