module Domain
  module Post
    class LikeButtonComponent < ApplicationComponent
      # @rbs (post: ::Post, current_user: ::User?) -> void
      def initialize(post:, current_user:)
        @post = post
        @current_user = current_user
      end

      # @rbs () -> bool
      def logged_in?
        @current_user.present?
      end
    end
  end
end
