class PostsController < ApplicationController
  before_action :authenticate_author!, only: [ :create, :update ]
  before_action :set_post, only: [ :update ]

  def index
    @posts = Post.includes(:user).order(first_published_at: :desc)
  end

  def show
    @post = Post.find_by(id: params[:id])
    head :not_found and return unless @post
  end

  def create
    draft = current_user.post_drafts.find_by(id: params[:draft_id])
    head :not_found and return unless draft

    if draft.post.present?
      redirect_to users_post_drafts_path, alert: "この下書きは既に公開されています"
      return
    end

    Post.create_from_draft!(draft)
    redirect_to users_post_drafts_path, notice: "記事を公開しました"
  end

  def update
    draft = current_user.post_drafts.find_by(id: params[:draft_id])
    head :not_found and return unless draft

    unless draft.post == @post
      redirect_to users_post_drafts_path, alert: "不正なリクエストです"
      return
    end

    @post.update_from_draft!(draft)
    redirect_to users_post_drafts_path, notice: "記事を更新しました"
  end

  private

  def authenticate_author!
    redirect_to root_path, alert: "権限がありません" unless current_user&.author?
  end

  def set_post
    @post = current_user.posts.find_by(id: params[:id])
    head :not_found and return unless @post
  end
end
