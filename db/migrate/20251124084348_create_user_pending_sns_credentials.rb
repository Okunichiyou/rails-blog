class CreateUserPendingSnsCredentials < ActiveRecord::Migration[8.0]
  def change
    create_table :user_pending_sns_credentials do |t|
      t.string :token, null: false
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :email, null: false
      t.string :name, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
    add_index :user_pending_sns_credentials, :token, unique: true
    add_index :user_pending_sns_credentials, [ :provider, :uid ]
    add_index :user_pending_sns_credentials, :expires_at
  end
end
