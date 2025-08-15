module Ui
  class Base < ViewComponent::Base
    private

    def filter_attribute(value:, white_list:)
      return value if white_list.include?(value)

      raise ArgumentError, "Invalid attribute value: '#{value}'. Must be one of #{white_list.join(', ')}."
    end

    def before_render
      @html_options.merge!(default_data_scope)
      add_default_class!(@html_options)
    end

    def default_data_scope
      { "data-scope":  self.class.to_s.underscore.tr("/", "-").tr("_", "-") }
    end

    def add_default_class!(html_options)
      if html_options[:class].nil?
        html_options[:class] = []
      end

      html_options[:class].push(self.class.to_s.underscore.tr("/", "-").tr("_", "-"))
    end
  end
end
