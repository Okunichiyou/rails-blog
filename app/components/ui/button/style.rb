module Ui
  module Button
    class Style
      attr_reader :category, :size, :variant

      # @rbs (category: Symbol, size: Symbol, ?variant: Symbol) -> void
      def initialize(category:, size:, variant: :default)
        @category = category
        @size = size
        @variant = variant
      end

    # @rbs (?String?) -> String
    def button_classes(extra_classes = nil)
      classes = [
        "group",
        "cursor-pointer font-bold px-10 py-6 text-center",
        "overflow-hidden relative transition-all duration-[400ms] ease-[cubic-bezier(0.175,0.885,0.32,2.2)]",
        "hover:px-[2.8rem] hover:py-[1.8rem]",
        "active:px-[3.1rem] active:py-[2.1rem]",
        "disabled:cursor-not-allowed disabled:opacity-50",
        "disabled:hover:px-10 disabled:hover:py-6",
        "rounded-[3rem]",
        border_class,
        @category,
        @variant == :danger ? "danger" : nil,
        size_class,
        extra_classes
      ].compact
      classes.join(" ")
    end

    # @rbs () -> String
    def size_class
      case @size
      when :full
        "w-full"
      when :large
        "w-[12.5rem]"
      when :medium
        "w-[7.5rem]"
      when :small
        "w-[5rem]"
      else
        ""
      end
    end

    # @rbs () -> String
    def text_color_class
      case @category
      when :primary
        if @variant == :danger
          "text-btn-primary-danger"
        else
          "text-btn-primary"
        end
      when :secondary
        if @variant == :danger
          "text-btn-secondary-danger"
        else
          "text-btn-secondary"
        end
      else
        ""
      end
    end

    # @rbs () -> String
    def tint_bg_class
      case @category
      when :primary
        if @variant == :danger
          "bg-btn-primary-danger"
        else
          "bg-btn-primary"
        end
      when :secondary
        if @variant == :danger
          "bg-btn-secondary-danger"
        else
          "bg-btn-secondary"
        end
      else
        ""
      end
    end

    # @rbs () -> String
    def border_class
      "border-none"
    end

    # @rbs () -> String
    def shadow_class
      case @category
      when :primary
        "shadow-[inset_2px_2px_1px_0_rgba(255,255,255,0.5),inset_-1px_-1px_1px_1px_rgba(255,255,255,0.5)]"
      when :secondary
        if @variant == :danger
          "shadow-[inset_1px_1px_1px_0_rgba(0,0,0,0.25),inset_-1px_-1px_1px_0_rgba(0,0,0,0.25)]"
        else
          "shadow-[inset_1px_1px_1px_0_rgba(0,0,0,0.25),inset_-1px_-1px_1px_0_rgba(0,0,0,0.25)]"
        end
      else
        ""
      end
    end
    end
  end
end
