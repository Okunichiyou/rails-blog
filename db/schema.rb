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

ActiveRecord::Schema[8.1].define(version: 2026_01_25_090028) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "post_drafts", force: :cascade do |t|
    t.text "content", default: "", null: false
    t.datetime "created_at", null: false
    t.integer "post_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["post_id"], name: "index_post_drafts_on_post_id", unique: true
    t.index ["user_id"], name: "index_post_drafts_on_user_id"
  end

  create_table "post_likes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "post_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["post_id"], name: "index_post_likes_on_post_id"
    t.index ["user_id", "post_id"], name: "index_post_likes_on_user_id_and_post_id", unique: true
    t.index ["user_id"], name: "index_post_likes_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "content", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "first_published_at", null: false
    t.datetime "last_published_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "view_count", default: 0, null: false
    t.index ["first_published_at"], name: "index_posts_on_first_published_at"
    t.index ["user_id"], name: "index_posts_on_user_id"
    t.index ["view_count"], name: "index_posts_on_view_count"
  end

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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "post_drafts", "posts"
  add_foreign_key "post_drafts", "users"
  add_foreign_key "post_likes", "posts"
  add_foreign_key "post_likes", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "user_database_authentications", "users"
  add_foreign_key "user_sns_credentials", "users"
end
