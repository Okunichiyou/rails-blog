# frozen_string_literal: true

class Users::PostsController < ApplicationController
  before_action :set_user
  before_action :authenticate_owner!, only: [ :edit, :destroy ]
  before_action :set_post, only: [ :edit, :destroy ]

  def index
    @posts = @user.posts.order(first_published_at: :desc)
  end

  def edit
    draft = @post.draft || create_draft_from_post
    redirect_to edit_users_post_draft_path(draft)
  end

  def destroy
    @post.destroy!
    redirect_to user_posts_path(@user), notice: "記事を削除しました"
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def authenticate_owner!
    redirect_to root_path, alert: "権限がありません" unless current_user&.id == @user.id
  end

  def set_post
    @post = @user.posts.find(params[:id])
  end

  def create_draft_from_post
    PostDraft.create!(
      user: current_user,
      post: @post,
      title: @post.title,
      content: @post.content
    )
  end
end
