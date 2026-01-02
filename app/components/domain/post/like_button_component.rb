module Domain
  module Post
    class LikeButtonComponent < ApplicationComponent
      # @rbs (post: ::Post, current_user: ::User?) -> void
      def initialize(post:, current_user:)
        @post = post
        @current_user = current_user
      end

      # @rbs () -> bool
      def liked?
        return false unless @current_user

        @post.post_likes.exists?(user: @current_user)
      end

      # @rbs () -> Integer
      def likes_count
        @post.post_likes.count
      end

      # @rbs () -> bool
      def logged_in?
        @current_user.present?
      end
    end
  end
end
