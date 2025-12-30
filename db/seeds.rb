# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding database..."

# Regular user (database_authentication)
puts "Creating regular user with database authentication..."
regular_user = User.create!(
  name: "regular_user",
  author: false
)

User::DatabaseAuthentication.create!(
  user: regular_user,
  email: "user@example.com",
  password: "password123",
  password_confirmation: "password123"
)

puts "Created regular user: user@example.com / password123"

# Author user (database_authentication)
puts "Creating author user with database authentication..."
author_user = User.create!(
  name: "author_user",
  author: true
)

User::DatabaseAuthentication.create!(
  user: author_user,
  email: "author@example.com",
  password: "password123",
  password_confirmation: "password123"
)

puts "Created author user: author@example.com / password123"

# PostDraft (下書き)
puts "Creating post drafts..."
PostDraft.create!(
  user: author_user,
  title: "下書き記事1",
  content: "<p>これは下書きの内容です。まだ公開されていません。</p>"
)

PostDraft.create!(
  user: author_user,
  title: "下書き記事2",
  content: "<p>もう一つの下書き記事です。</p><p>複数の段落があります。</p>"
)

puts "Created #{PostDraft.count} post drafts"

# Post (公開記事)
puts "Creating posts..."
Post.create!(
  user: author_user,
  title: "最初の公開記事",
  content: "<p>これは公開された記事です。</p><p>誰でも閲覧できます。</p>",
  published_at: Time.current
)

Post.create!(
  user: author_user,
  title: "2つ目の公開記事",
  content: "<h2>見出し</h2><p>本文の内容です。</p><ul><li>リスト項目1</li><li>リスト項目2</li></ul>",
  published_at: 1.day.ago
)

puts "Created #{Post.count} posts"

puts "Seeding completed!"
