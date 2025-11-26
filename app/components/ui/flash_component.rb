module Ui
  class FlashComponent < ApplicationComponent
    renders_one :flash_content

    FLASH_TYPES = %i[info notice warn alert].freeze

    # @rbs (flash_type: Symbol, **nil | String) -> void
    def initialize(
      flash_type:,
      **html_options
    )
      @flash_type = filter_attribute(value: flash_type, white_list: FLASH_TYPES)
      @html_options = html_options.merge(class: flash_classes(html_options[:class]))
    end

    private

    # @rbs (String?) -> String
    def flash_classes(extra_classes)
      classes = [
        "rounded-sm p-4",
        flash_type_class,
        extra_classes
      ].compact
      classes.join(" ")
    end

    # @rbs () -> String
    def flash_type_class
      case @flash_type
      when :info
        "bg-info text-info"
      when :notice
        "bg-notice text-notice"
      when :warn
        "bg-warn text-warn"
      when :alert
        "bg-alert text-alert"
      else
        ""
      end
    end
  end
end
