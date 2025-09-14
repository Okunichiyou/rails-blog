module Ui
  class FlashComponent < Ui::Base
    renders_one :flash_content

    FLASH_TYPES = %i[info notice warn alert].freeze

    def initialize(
      flash_type:,
      html_options: {}
    )
      @flash_type = filter_attribute(value: flash_type, white_list: FLASH_TYPES)
      @html_options = build_html_options(html_options)
    end

    private

    def build_html_options(html_options)
      html_options.merge({ class: flash_classes(html_options) })
    end

    def flash_classes(html_options)
      classes = []
      classes.push(@flash_type.to_s)

      argument_classes = html_options[:class]
      classes.concat(argument_classes.split) if argument_classes.present?

      classes
    end
  end
end
