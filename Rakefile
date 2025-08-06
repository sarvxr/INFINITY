require 'sinatra/activerecord/rake'
require 'dotenv/load'

namespace :db do
  desc "Create the database"
  task :create do
    require_relative 'db/setup'
    puts "Database created successfully!"
  end

  desc "Drop the database"
  task :drop do
    File.delete('db/development.sqlite3') if File.exist?('db/development.sqlite3')
    puts "Database dropped successfully!"
  end

  desc "Reset the database"
  task :reset => [:drop, :create] do
    puts "Database reset successfully!"
  end

  desc "Setup the database"
  task :setup do
    require_relative 'db/setup'
    puts "Database setup completed!"
  end

  desc "Seed the database"
  task :seed do
    # Add seed data here if needed
    puts "Database seeded successfully!"
  end
end

namespace :app do
  desc "Start the application"
  task :start do
    system "bundle exec rackup config.ru -p 4567"
  end

  desc "Start Sidekiq worker"
  task :worker do
    system "bundle exec sidekiq -r ./app.rb"
  end

  desc "Start both web and worker"
  task :start_all do
    puts "Starting web server..."
    fork { system "bundle exec rackup config.ru -p 4567" }
    puts "Starting worker..."
    fork { system "bundle exec sidekiq -r ./app.rb" }
    puts "Both services started. Press Ctrl+C to stop."
    Process.wait
  end
end

namespace :check do
  desc "Check for common issues"
  task :issues do
    puts "Checking for common issues..."
    
    # Check if .env file exists
    unless File.exist?('.env')
      puts "⚠️  .env file not found. Please copy env.example to .env and configure it."
    end
    
    # Check if database exists
    unless File.exist?('db/development.sqlite3')
      puts "⚠️  Database not found. Run 'rake db:setup' to create it."
    end
    
    # Check if target files exist
    unless File.exist?('fw.txt') || File.exist?('fwl.txt')
      puts "⚠️  No target files found (fw.txt or fwl.txt). The automation will use default targets."
    end
    
    puts "Check completed!"
  end
end 