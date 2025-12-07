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
puts "Seeding completed!"
