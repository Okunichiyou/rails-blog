class PostPresenter
  class << self
    # @rbs (content: String, limit: Integer) -> String
    def beginning_of_content(content:, limit: 100)
      return "" if content.blank?

      plain_text = ActionController::Base.helpers.strip_tags(content)
      plain_text.truncate(limit)
    end
  end
end
