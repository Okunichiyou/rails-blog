class PostDraft < ApplicationRecord
  belongs_to :user
  belongs_to :post, optional: true

  has_rich_text :content

  validates :title, presence: true, length: { maximum: 255 }
  validates :post_id, uniqueness: true, allow_nil: true

  # @rbs () -> bool
  def new_draft?
    post_id.nil?
  end
end
