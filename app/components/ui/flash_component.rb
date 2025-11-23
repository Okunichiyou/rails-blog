module Ui
  class FlashComponent < ApplicationComponent
    renders_one :flash_content

    FLASH_TYPES = %i[info notice warn alert].freeze

    def initialize(
      flash_type:,
      **html_options
    )
      @flash_type = filter_attribute(value: flash_type, white_list: FLASH_TYPES)
      @html_options = html_options.merge(class: flash_classes(html_options[:class]))
    end

    private

    def flash_classes(extra_classes)
      classes = [
        "rounded-[var(--radius-sm)] p-4",
        flash_type_class,
        extra_classes
      ].compact
      classes.join(" ")
    end

    def flash_type_class
      case @flash_type
      when :info
        "bg-[var(--color-bg-info)] text-[var(--color-text-info)]"
      when :notice
        "bg-[var(--color-bg-notice)] text-[var(--color-text-notice)]"
      when :warn
        "bg-[var(--color-bg-warn)] text-[var(--color-text-warn)]"
      when :alert
        "bg-[var(--color-bg-alert)] text-[var(--color-text-alert)]"
      end
    end
  end
end
