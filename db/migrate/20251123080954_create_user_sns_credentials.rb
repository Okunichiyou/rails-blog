class CreateUserSnsCredentials < ActiveRecord::Migration[8.0]
  def change
    create_table :user_sns_credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :email, null: false
      t.timestamps
    end

    add_index :user_sns_credentials, [ :provider, :uid ], unique: true
    add_index :user_sns_credentials, [ :provider, :email ], unique: true
  end
end
