class Post < ApplicationRecord
  belongs_to :user
  has_one :draft, class_name: "PostDraft", dependent: :nullify

  validates :title, presence: true, length: { maximum: 255 }
  validates :first_published_at, presence: true
  validates :last_published_at, presence: true

  # @rbs (PostDraft) -> Post
  def self.create_from_draft!(draft)
    now = Time.current
    transaction do
      post = create!(
        user: draft.user,
        title: draft.title,
        content: draft.content,
        first_published_at: now,
        last_published_at: now
      )
      draft.update!(post: post)
      post
    end
  end

  # @rbs (PostDraft) -> Post
  def update_from_draft!(draft)
    transaction do
      update!(title: draft.title, content: draft.content, last_published_at: Time.current)
      self
    end
  end
end
