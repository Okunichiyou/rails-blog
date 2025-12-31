class RenamePublishedAtAndAddLastPublishedAtToPosts < ActiveRecord::Migration[8.1]
  def up
    rename_column :posts, :published_at, :first_published_at
    add_column :posts, :last_published_at, :datetime

    execute "UPDATE posts SET last_published_at = first_published_at"

    change_column_null :posts, :last_published_at, false
  end

  def down
    remove_column :posts, :last_published_at
    rename_column :posts, :first_published_at, :published_at
  end
end
