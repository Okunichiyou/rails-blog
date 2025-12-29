class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.datetime :published_at, null: false

      t.timestamps
    end
    add_index :posts, :published_at
  end
end
