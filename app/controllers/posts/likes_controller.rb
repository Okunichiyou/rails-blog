class Posts::LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    @post.post_likes.find_or_create_by!(user: current_user)
    redirect_to post_path(@post)
  end

  def destroy
    @post.post_likes.find_by(user: current_user)&.destroy
    redirect_to post_path(@post)
  end

  private

  def authenticate_user!
    redirect_to login_path, alert: "ログインしてください" unless current_user
  end

  def set_post
    @post = Post.find_by(id: params[:post_id])
    head :not_found and return unless @post
  end
end
