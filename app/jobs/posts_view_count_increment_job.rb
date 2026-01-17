class PostsViewCountIncrementJob < ApplicationJob
  queue_as :default

  def perform(post)
    post.increment!(:view_count)
  end
end
