source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.1'

gem 'rails', '~> 8.0.2'
gem 'pg'
gem 'puma', '~> 6.0'

gem 'jbuilder', '~> 2.7'

gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
end

group :test do
  gem 'rspec-rails'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'mastodon-api', require: 'mastodon'
gem 'ruby-mp3info'

gem 'ostruct'
gem 'aws-sdk-s3', '~> 1.146', '>= 1.146.1'
gem 'sorcery'
gem 'pundit'
gem 'jwt'
gem 'attr_encrypted', '~> 4.1.0'
