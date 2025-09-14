module Ui
  class PanelComponent < Ui::Base
    renders_one :panel_content

    SIZE_OPTIONS = %i[full large medium small].freeze

    def initialize(
      size:,
      panel_class: "",
      html_options: {}
    )
      @size = filter_attribute(value: size, white_list: SIZE_OPTIONS)
      @panel_class = panel_class.split
      @html_options = build_html_options(html_options)
    end

    private

    def build_html_options(html_options)
      html_options.merge({ class: panel_classes })
    end

    def panel_classes
      classes = []
      classes.push(@size.to_s)
      classes.concat(@panel_class)
    end
  end
end
