# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_24_084348) do
  create_table "user_confirmations", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token", null: false
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_user_confirmations_on_confirmation_token", unique: true
    t.index ["unconfirmed_email"], name: "index_user_confirmations_on_unconfirmed_email", unique: true
  end

  create_table "user_database_authentications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["email"], name: "index_user_database_authentications_on_email", unique: true
    t.index ["user_id"], name: "index_user_database_authentications_on_user_id"
  end

  create_table "user_pending_sns_credentials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.string "name", null: false
    t.string "provider", null: false
    t.string "token", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_user_pending_sns_credentials_on_expires_at"
    t.index ["provider", "uid"], name: "index_user_pending_sns_credentials_on_provider_and_uid"
    t.index ["token"], name: "index_user_pending_sns_credentials_on_token", unique: true
  end

  create_table "user_sns_credentials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["provider", "email"], name: "index_user_sns_credentials_on_provider_and_email", unique: true
    t.index ["provider", "uid"], name: "index_user_sns_credentials_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_user_sns_credentials_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "author", default: false, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "user_database_authentications", "users"
  add_foreign_key "user_sns_credentials", "users"
end
