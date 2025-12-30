class PostDraftsController < ApplicationController
  before_action :authenticate_author!
  before_action :set_post_draft, only: [ :edit, :update, :destroy ]

  def index
    @post_drafts = current_user.post_drafts.order(updated_at: :desc)
  end

  def new
    @form = PostDraftForm.new(user: current_user)
  end

  def create
    @form = PostDraftForm.new(user: current_user, **post_draft_params)

    if @form.save
      redirect_to post_drafts_path, notice: "下書きを保存しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @form = PostDraftForm.new(
      user: current_user,
      post_draft: @post_draft,
      title: @post_draft.title,
      content: @post_draft.content
    )
  end

  def update
    @form = PostDraftForm.new(
      user: current_user,
      post_draft: @post_draft,
      **post_draft_params
    )

    if @form.save
      redirect_to post_drafts_path, notice: "下書きを更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @post_draft.destroy
    redirect_to post_drafts_path, notice: "下書きを削除しました"
  end

  private

  def authenticate_author!
    redirect_to root_path, alert: "権限がありません" unless current_user&.author?
  end

  def set_post_draft
    @post_draft = current_user.post_drafts.find(params[:id])
  end

  def post_draft_params
    params.require(:post_draft).permit(:title, :content).to_h.symbolize_keys
  end
end
