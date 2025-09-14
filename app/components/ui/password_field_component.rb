module Ui
  class PasswordFieldComponent < Ui::Base
    SIZE_OPTIONS = %i[full large medium small].freeze

    def initialize(
      builder:,
      method:,
      size:,
      html_options: {}
    )
      @builder = builder
      @method = method
      @size = filter_attribute(value: size, white_list: SIZE_OPTIONS)
      @html_options = build_html_options(html_options)
    end

    private

    def build_html_options(html_options)
      html_options.merge({ class: password_field_classes(html_options) })
    end

    def password_field_classes(html_options)
      classes = []
      classes.push("text-field-component")
      classes.push(@size.to_s)

      argument_classes = html_options[:class]
      classes.concat(argument_classes.split) if argument_classes.present?

      classes
    end
  end
end
