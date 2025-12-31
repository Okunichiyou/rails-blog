class CreatePostDrafts < ActiveRecord::Migration[8.1]
  def change
    create_table :post_drafts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, foreign_key: true, index: { unique: true }
      t.string :title, null: false

      t.timestamps
    end
  end
end
