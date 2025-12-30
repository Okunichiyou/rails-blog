# frozen_string_literal: true

class Users::PostsController < ApplicationController
  before_action :set_user
  before_action :authenticate_author!, only: [ :destroy ]
  before_action :set_post, only: [ :destroy ]

  def index
    @posts = @user.posts.order(first_published_at: :desc)
  end

  def destroy
    @post.destroy!
    redirect_to user_posts_path(@user), notice: "記事を削除しました"
  end

  private

  def set_user
    @user = User.find_by(id: params[:user_id])
    head :not_found and return unless @user
  end

  def authenticate_author!
    redirect_to root_path, alert: "権限がありません" unless current_user&.id == @user.id
  end

  def set_post
    @post = @user.posts.find_by(id: params[:id])
    head :not_found and return unless @post
  end
end
