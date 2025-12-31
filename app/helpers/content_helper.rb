# frozen_string_literal: true

module ContentHelper
  ALLOWED_TAGS = %w[
    p br
    h1 h2 h3 h4 h5 h6
    strong em s code
    ul ol li
    blockquote pre
    a img
  ].freeze

  ALLOWED_ATTRIBUTES = %w[
    href target rel
    src alt
    data-callout
    class
  ].freeze

  # @rbs (String?) -> ActiveSupport::SafeBuffer
  def sanitize_tiptap_content(content)
    return "".html_safe if content.blank?

    sanitize(content, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
  end
end
