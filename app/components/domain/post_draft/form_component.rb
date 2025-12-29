module Domain
  module PostDraft
    class FormComponent < ApplicationComponent
      # @rbs (form: PostDraftForm, url: String, ?method: Symbol) -> void
      def initialize(form:, url:, method: :post)
        @form = form
        @url = url
        @method = method
      end
    end
  end
end
