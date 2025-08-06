# Troubleshooting Guide

## Common Issues and Solutions

### 1. Ruby Installation Issues

**Problem**: `ruby: command not found`

**Solution**:
- Install Ruby 3.2.0 or higher
- Windows: Download from https://rubyinstaller.org/
- macOS: Use `brew install ruby`
- Linux: Use your package manager or rbenv/rvm

### 2. Database Issues

**Problem**: Database connection errors

**Solution**:
```bash
# Reset database
bundle exec rake db:reset

# Or manually setup
ruby db/setup.rb
```

**Problem**: Migration errors

**Solution**:
```bash
# Drop and recreate database
bundle exec rake db:drop
bundle exec rake db:setup
```

### 3. Gem Installation Issues

**Problem**: `bundle install` fails

**Solution**:
```bash
# Update bundler
gem update bundler

# Install gems with verbose output
bundle install --verbose

# If specific gems fail, try:
gem install [gem_name] --verbose
```

### 4. Redis Issues

**Problem**: Redis connection errors

**Solution**:
```bash
# Install Redis
# Windows: Download from https://redis.io/download
# macOS: brew install redis
# Linux: sudo apt-get install redis-server

# Start Redis
redis-server

# Test connection
redis-cli ping
```

### 5. Port Already in Use

**Problem**: Port 4567 is already in use

**Solution**:
```bash
# Find process using port
lsof -i :4567

# Kill process
kill -9 [PID]

# Or use different port
bundle exec rackup config.ru -p 4568
```

### 6. Authentication Issues

**Problem**: JWT token errors

**Solution**:
- Clear browser localStorage
- Check JWT_SECRET in .env file
- Ensure token is being sent in Authorization header

### 7. Facebook API Issues

**Problem**: Facebook authentication fails

**Solution**:
- Check Facebook credentials
- Ensure account is not locked
- Try with different Facebook account
- Check internet connection

### 8. Background Job Issues

**Problem**: Sidekiq jobs not running

**Solution**:
```bash
# Start Sidekiq manually
bundle exec sidekiq -r ./app.rb

# Check Redis connection
redis-cli ping

# Check Sidekiq dashboard
# Visit: http://localhost:4567/sidekiq
```

### 9. File Permission Issues

**Problem**: Permission denied errors

**Solution**:
```bash
# Make startup script executable
chmod +x start.sh

# Check file permissions
ls -la

# Fix permissions if needed
chmod 755 *.rb
chmod 755 *.sh
```

### 10. Environment Variables

**Problem**: Missing environment variables

**Solution**:
```bash
# Copy example file
cp env.example .env

# Edit .env file with your values
nano .env
```

### 11. Memory Issues

**Problem**: Out of memory errors

**Solution**:
- Close other applications
- Increase system memory
- Use lighter database (SQLite instead of PostgreSQL)

### 12. Network Issues

**Problem**: Cannot connect to external APIs

**Solution**:
- Check internet connection
- Check firewall settings
- Try with VPN if needed
- Check proxy settings

## Debug Mode

To run in debug mode:

```bash
# Set debug environment
export RACK_ENV=development
export DEBUG=true

# Start with debug output
bundle exec rackup config.ru -p 4567 --debug
```

## Log Files

Check these locations for logs:

- Application logs: Console output
- Database logs: `db/development.sqlite3`
- Sidekiq logs: Console output
- Error logs: Check browser console

## Performance Issues

**Problem**: Slow response times

**Solution**:
- Use production database (PostgreSQL)
- Enable caching
- Optimize database queries
- Use CDN for static assets

## Security Issues

**Problem**: Security vulnerabilities

**Solution**:
- Update all gems: `bundle update`
- Use HTTPS in production
- Set strong JWT_SECRET
- Enable CORS properly
- Validate all inputs

## Testing

Run tests to verify functionality:

```bash
# Run all tests
ruby test/test_app.rb

# Run specific test
ruby test/test_app.rb -n test_homepage_returns_200
```

## Getting Help

If you're still experiencing issues:

1. Check the logs for error messages
2. Run the diagnostic command: `bundle exec rake check:issues`
3. Try the test suite: `ruby test/test_app.rb`
4. Check the GitHub issues page
5. Create a new issue with:
   - Error message
   - Steps to reproduce
   - System information
   - Log files

## System Requirements

- Ruby 3.2.0+
- SQLite3 or PostgreSQL
- Redis (optional, for background jobs)
- 512MB RAM minimum
- 1GB disk space

## Performance Tuning

For better performance:

1. Use PostgreSQL instead of SQLite
2. Enable Redis for caching
3. Use a production web server (Puma)
4. Enable compression
5. Use CDN for static assets
6. Optimize database queries
7. Enable background job processing 