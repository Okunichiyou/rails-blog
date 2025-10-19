class RenameUserRegistrationsToUserConfirmations < ActiveRecord::Migration[8.0]
  def change
    rename_table :user_registrations, :user_confirmations
  end
end
