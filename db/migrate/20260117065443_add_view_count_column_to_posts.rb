class AddViewCountColumnToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :view_count, :integer, null: false, default: 0
    add_index :posts, :view_count
  end
end
