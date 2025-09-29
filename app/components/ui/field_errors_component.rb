module Ui
  class FieldErrorsComponent < Ui::Base
    def initialize(error_messages:)
      @error_messages = error_messages
      @html_options = {}
    end
  end
end
