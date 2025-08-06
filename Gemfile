source 'https://rubygems.org'

ruby '3.4.4'

# Web Framework
gem 'sinatra', '~> 3.0'
gem 'sinatra-contrib', '~> 3.0'
gem 'rack', '~> 3.0'

# Database
gem 'sqlite3', '~> 1.6', group: :development
gem 'pg', '~> 1.5', group: :production
gem 'activerecord', '~> 7.0'
gem 'sinatra-activerecord', '~> 2.0'

# Authentication & Security
gem 'bcrypt', '~> 3.1'
gem 'jwt', '~> 2.7'
gem 'rack-protection', '~> 3.0'

# API & HTTP
gem 'httparty', '~> 0.21'
gem 'json', '~> 2.6'

# Background Jobs
gem 'sidekiq', '~> 7.0'
gem 'redis', '~> 5.0'

# Utilities
gem 'dotenv', '~> 0.3'
gem 'erb', '~> 4.0'

# Web Server
gem 'puma', '~> 6.0'

group :development do
  gem 'rerun', '~> 0.14'
  gem 'rack-livereload', '~> 0.3'
  gem 'thin', '~> 1.8'
end

group :test do
  gem 'rspec', '~> 3.12'
  gem 'rack-test', '~> 2.0'
end 