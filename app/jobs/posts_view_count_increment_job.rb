class PostsViewCountIncrementJob < ApplicationJob
  queue_as :default

  # @rbs (Post) -> Post
  def perform(post)
    post.increment!(:view_count)
  end
end
