module Ui
  module Button
    class IconComponent < ApplicationComponent
      CATEGORY_OPTIONS = %i[primary secondary].freeze
      SIZE_OPTIONS = %i[full large medium small].freeze
      TYPE_OPTIONS = %i[button submit reset].freeze
      VARIANT_OPTIONS = %i[default danger].freeze

      # @rbs (category: Symbol, size: Symbol, text: String, ?type: Symbol, ?variant: Symbol, ?icon: ActiveSupport::SafeBuffer | nil, ?icon_position: Symbol, **nil | bool | String) -> void
      def initialize(
        category:,
        size:,
        type: :button,
        variant: :default,
        text:,
        icon: nil,
        icon_position: :left,
        **html_options
      )
        @category = filter_attribute(value: category, white_list: CATEGORY_OPTIONS)
        @size = filter_attribute(value: size, white_list: SIZE_OPTIONS)
        @type = filter_attribute(value: type, white_list: TYPE_OPTIONS)
        @variant = filter_attribute(value: variant, white_list: VARIANT_OPTIONS)
        @text = text
        @icon = icon
        @icon_position = icon_position.to_sym
        @style = Style.new(category: @category, size: @size, variant: @variant)
        @html_options = html_options.merge(type: @type.to_s, class: @style.button_classes(html_options[:class]))
      end

      private

      # @rbs () -> String
      def text_color_class
        @style.text_color_class
      end

      # @rbs () -> String
      def tint_bg_class
        @style.tint_bg_class
      end

      # @rbs () -> String
      def shadow_class
        @style.shadow_class
      end
    end
  end
end
