module Ui
  module Icon
    class PlusComponent < ApplicationComponent
      SIZE_OPTIONS = %i[sm md lg].freeze

      # @rbs (?size: Symbol, **String | nil) -> void
      def initialize(size: :md, **html_options)
        @size = filter_attribute(value: size, white_list: SIZE_OPTIONS)
        @html_options = html_options.merge(class: icon_classes(html_options[:class]))
      end

      private

      # @rbs (String?) -> String
      def icon_classes(extra_classes)
        [ size_class, extra_classes ].compact.join(" ")
      end

      # @rbs () -> String
      def size_class
        case @size
        when :sm then "w-4 h-4 max-w-full"
        when :lg then "w-6 h-6 max-w-full"
        else "w-5 h-5" # :md (default)
        end
      end
    end
  end
end
