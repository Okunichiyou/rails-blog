module Page
  class Base < ViewComponent::Base
    private

    def before_render
      @html_options ||= {}
      @html_options.merge!(default_data_scope)
      add_default_class!(@html_options)
    end

    def default_data_scope
      { "data-scope":  self.class.to_s.underscore.tr("/", "-").tr("_", "-") }
    end

    def add_default_class!(html_options)
      html_options[:class] ||= []

      html_options[:class].push(self.class.to_s.underscore.tr("/", "-").tr("_", "-"))
    end
  end
end
