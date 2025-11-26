module Ui
  class FieldErrorsComponent < ApplicationComponent
    # @rbs (error_messages: Array[untyped], **nil) -> void
    def initialize(error_messages:, **html_options)
      @error_messages = error_messages
      @html_options = html_options.merge(class: error_classes(html_options[:class]))
    end

    private

    # @rbs (nil) -> String
    def error_classes(extra_classes)
      classes = [
        "list-disc list-inside mt-1 mb-0 text-alert-inline text-size-note [&>li]:my-[2px]",
        extra_classes
      ].compact
      classes.join(" ")
    end
  end
end
