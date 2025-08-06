#!/bin/bash

echo "🚀 Starting Infinity - Ultimate Facebook Follower Manager"
echo "=================================================="

# Check if Ruby is installed
if ! command -v ruby &> /dev/null; then
    echo "❌ Ruby is not installed. Please install Ruby 3.2.0 or higher."
    echo "   Visit: https://www.ruby-lang.org/en/documentation/installation/"
    exit 1
fi

# Check Ruby version
RUBY_VERSION=$(ruby -v | cut -d' ' -f2 | cut -d'p' -f1)
REQUIRED_VERSION="3.2.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$RUBY_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "❌ Ruby version $RUBY_VERSION is too old. Please install Ruby 3.2.0 or higher."
    exit 1
fi

echo "✅ Ruby version $RUBY_VERSION detected"

# Check if Bundler is installed
if ! command -v bundle &> /dev/null; then
    echo "📦 Installing Bundler..."
    gem install bundler
fi

# Install dependencies
echo "📦 Installing dependencies..."
if ! bundle install; then
    echo "❌ Failed to install dependencies. Please check your Gemfile."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "⚙️  Creating .env file..."
    cp env.example .env
    echo "⚠️  Please edit .env file with your configuration before continuing."
    echo "   Press Enter when ready to continue..."
    read
fi

# Create database directory
mkdir -p db

# Set up database
echo "🗄️  Setting up database..."
if ! bundle exec rake db:setup; then
    echo "❌ Failed to setup database. Trying alternative method..."
    if ! ruby db/setup.rb; then
        echo "❌ Database setup failed. Please check the error messages above."
        exit 1
    fi
fi

# Check if Redis is running
if ! command -v redis-cli &> /dev/null; then
    echo "⚠️  Redis is not installed. Please install Redis for background job processing."
    echo "   You can still run the web server without Redis."
    echo "   Press Enter to continue without Redis..."
    read
    REDIS_AVAILABLE=false
else
    if redis-cli ping &> /dev/null; then
        echo "✅ Redis is running"
        REDIS_AVAILABLE=true
    else
        echo "⚠️  Redis is not running. Starting Redis..."
        redis-server --daemonize yes
        sleep 2
        if redis-cli ping &> /dev/null; then
            echo "✅ Redis started successfully"
            REDIS_AVAILABLE=true
        else
            echo "❌ Failed to start Redis. Continuing without background jobs..."
            REDIS_AVAILABLE=false
        fi
    fi
fi

# Check for common issues
echo "🔍 Checking for common issues..."
bundle exec rake check:issues

echo ""
echo "🎉 Setup complete! Starting the application..."
echo ""

# Start the application
if [ "$REDIS_AVAILABLE" = true ]; then
    echo "🌐 Starting web server and background worker..."
    echo "   Web server: http://localhost:4567"
    echo "   Press Ctrl+C to stop both services"
    echo ""
    
    # Start both web server and worker
    bundle exec rake app:start_all
else
    echo "🌐 Starting web server only..."
    echo "   Web server: http://localhost:4567"
    echo "   Press Ctrl+C to stop"
    echo ""
    
    # Start only web server
    bundle exec rackup config.ru -p 4567
fi 