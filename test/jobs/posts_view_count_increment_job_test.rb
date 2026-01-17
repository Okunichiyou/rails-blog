require "test_helper"

class PostsViewCountIncrementJobTest < ActiveJob::TestCase
  test "view_countが1つ増えること" do
    post = posts(:one)

    assert_difference -> { post.view_count }, 1 do
      PostsViewCountIncrementJob.perform_now(post)
    end
  end

  test "updated_atが更新されないこと" do
    post = posts(:one)

    assert_no_difference -> { post.updated_at } do
      PostsViewCountIncrementJob.perform_now(post)
    end
  end
end
