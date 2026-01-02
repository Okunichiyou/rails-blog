module Domain
  module Post
    class LikeButtonComponent < ApplicationComponent
      attr_reader :frame_id

      # @rbs (post: ::Post, current_user: ::User?, id: String) -> void
      def initialize(post:, current_user:, id:)
        @post = post
        @current_user = current_user
        @frame_id = "post-like-button-#{id}-#{post.id}"
      end

      # @rbs () -> bool
      def logged_in?
        @current_user.present?
      end
    end
  end
end
