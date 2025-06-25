source "https://rubygems.org"

gem "importmap-rails"
gem "jbuilder"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", "~> 8.0.2"
gem "sqlite3", ">= 2.1"
gem "stimulus-rails"
gem "turbo-rails"

gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "solid_cable"
gem "solid_cache"
gem "solid_queue"

gem "bootsnap", require: false

gem "kamal", require: false

gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  gem "brakeman", require: false

  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
