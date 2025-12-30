class Post < ApplicationRecord
  belongs_to :user
  has_one :draft, class_name: "PostDraft", dependent: :nullify

  has_rich_text :content

  validates :title, presence: true, length: { maximum: 255 }
  validates :published_at, presence: true

  # @rbs (PostDraft) -> Post
  def self.create_from_draft!(draft)
    transaction do
      post = create!(
        user: draft.user,
        title: draft.title,
        published_at: Time.current
      )
      post.content = draft.content
      draft.update!(post: post)
      post
    end
  end

  # @rbs (PostDraft) -> Post
  def update_from_draft!(draft)
    transaction do
      update!(title: draft.title)
      self.content = draft.content.body
      save!
      self
    end
  end
end
