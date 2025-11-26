module Ui
  class PanelComponent < ApplicationComponent
    renders_one :panel_content

    SIZE_OPTIONS = %i[full large medium small].freeze

    # @rbs (size: Symbol, **untyped) -> void
    def initialize(
      size:,
      **html_options
    )
      @size = filter_attribute(value: size, white_list: SIZE_OPTIONS)
      @html_options = html_options.merge(class: panel_classes(html_options[:class]))
    end

    private

    # @rbs (untyped) -> String
    def panel_classes(extra_classes)
      classes = [
        "bg-surface",
        "rounded-lg",
        "p-4",
        "shadow-default",
        size_class,
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
        "w-[800px]"
      when :medium
        "w-[400px]"
      when :small
        "w-[200px]"
      else
        ""
      end
    end
  end
end
