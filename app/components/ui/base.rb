module Ui
  class Base < ViewComponent::Base
    private

    def filter_attribute(value:, white_list:)
      return value if white_list.include?(value)

      raise ArgumentError, "Invalid attribute value: '#{value}'. Must be one of #{white_list.join(', ')}."
    end

    def build_html_options(html_options)
      options = {}
      options["data-scope"] = self.class.to_s.underscore.tr("/", "-").tr("_", "-")
      options.merge(html_options)
    end
  end
end
