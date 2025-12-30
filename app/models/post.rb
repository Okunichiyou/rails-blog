class Post < ApplicationRecord
  belongs_to :user
  has_one :draft, class_name: "PostDraft", dependent: :nullify

  validates :title, presence: true, length: { maximum: 255 }
  validates :published_at, presence: true

  # @rbs (PostDraft) -> Post
  def self.create_from_draft!(draft)
    transaction do
      post = create!(
        user: draft.user,
        title: draft.title,
        content: draft.content,
        published_at: Time.current
      )
      draft.update!(post: post)
      post
    end
  end

  # @rbs (PostDraft) -> Post
  def update_from_draft!(draft)
    transaction do
      update!(title: draft.title, content: draft.content)
      self
    end
  end
end
