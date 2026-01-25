class AlterContentColumnToNotNull < ActiveRecord::Migration[8.1]
  def change
    change_column :posts, :content, :text, null: false, default: ""
    change_column :post_drafts, :content, :text, null: false, default: ""
  end
end
