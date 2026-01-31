class AddLockableToDatabaseAuthentication < ActiveRecord::Migration[8.1]
  def change
    change_table :user_database_authentications, bulk: true do |t|
      t.integer :failed_attempts, default: 0, null: false
      t.datetime :locked_at
    end
  end
end
