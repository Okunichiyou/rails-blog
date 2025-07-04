# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    add_index :users, :name, unique: true
  end
end
