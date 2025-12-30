class AddContentColumnToPostsAndPostDrafts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :content, :text
    add_column :post_drafts, :content, :text
  end
end
