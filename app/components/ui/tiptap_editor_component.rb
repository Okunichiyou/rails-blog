module Ui
  class TiptapEditorComponent < ApplicationComponent
    VARIANT_OPTIONS = %i[default alert].freeze

    # @rbs (builder: ActionView::Helpers::FormBuilder, method: Symbol, ?variant: Symbol, **untyped) -> void
    def initialize(
      builder:,
      method:,
      variant: :default,
      **html_options
    )
      @builder = builder
      @method = method
      @variant = filter_attribute(value: variant, white_list: VARIANT_OPTIONS)
      @html_options = html_options
    end

    private

    # @rbs () -> String
    def variant_class
      return "" if @variant == :default

      "border-alert" # :alert
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
