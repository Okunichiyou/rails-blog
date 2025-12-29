class PostDraftForm < ApplicationForm
  attribute :title, :string
  attribute :content, :string

  attr_reader :post_draft

  validates_associated :post_draft

  # @rbs (user: User, ?post_draft: PostDraft?, **untyped) -> void
  def initialize(user:, post_draft: nil, **attributes)
    @user = user
    @existing_draft = post_draft
    super(**attributes)
  end

  # @rbs () -> bool
  def save
    build_post_draft
    return false unless valid?

    post_draft.save
  end

  private

  # @rbs () -> void
  def build_post_draft
    @post_draft = @existing_draft || @user.post_drafts.build
    @post_draft.assign_attributes(
      title: title,
      content: content
    )
  end
end
