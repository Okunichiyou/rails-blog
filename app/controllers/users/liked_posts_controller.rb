class Users::LikedPostsController < ApplicationController
  before_action :authenticate_user!

  def index
    @posts = current_user.liked_posts.includes(:user).order("post_likes.created_at DESC")
  end
end
