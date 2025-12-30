module Ui
  class TiptapEditorComponent < ApplicationComponent
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
      @html_options = html_options
    end

    private

    # @rbs () -> String
    def editor_classes
      classes = [
        "tiptap-wrapper",
        "border border-default rounded-md",
        "bg-surface",
        variant_class
      ].compact
      classes.join(" ")
    end

    # @rbs () -> String
    def content_area_classes
      classes = [
        "tiptap-content-area",
        size_class
      ].compact
      classes.join(" ")
    end

    # @rbs () -> String
    def size_class
      case @size
      when :full
        "min-h-[20rem]"
      when :large
        "min-h-[15rem]"
      when :medium
        "min-h-[10rem]"
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

    # @rbs () -> String
    def current_content
      object = @builder.object
      return "" unless object.respond_to?(@method)

      content = object.public_send(@method)
      content.to_s
    end

    # @rbs () -> String
    def input_name
      "#{@builder.object_name}[#{@method}]"
    end
  end
end
