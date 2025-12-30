class PostsController < ApplicationController
  before_action :authenticate_author!
  before_action :set_post, only: [ :update ]

  def create
    draft = current_user.post_drafts.find(params[:draft_id])

    if draft.post.present?
      redirect_to post_drafts_path, alert: "この下書きは既に公開されています"
      return
    end

    Post.create_from_draft!(draft)
    redirect_to post_drafts_path, notice: "記事を公開しました"
  end

  def update
    draft = current_user.post_drafts.find(params[:draft_id])

    unless draft.post == @post
      redirect_to post_drafts_path, alert: "不正なリクエストです"
      return
    end

    @post.update_from_draft!(draft)
    redirect_to post_drafts_path, notice: "記事を更新しました"
  end

  private

  def authenticate_author!
    redirect_to root_path, alert: "権限がありません" unless current_user&.author?
  end

  def set_post
    @post = current_user.posts.find(params[:id])
  end
end
