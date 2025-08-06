# Infinity - Ultimate Facebook Follower Manager

A professional-grade web application for managing Facebook follower automation with advanced analytics, real-time monitoring, and intelligent follower management.

## 🌟 Features

- **Smart Automation**: Intelligent follower management with advanced algorithms and rate limiting protection
- **Real-time Analytics**: Comprehensive analytics dashboard with detailed insights and performance metrics
- **Account Security**: Advanced security features to protect your accounts from detection and suspension
- **Multi-Account Management**: Manage multiple Facebook accounts from a single, unified dashboard
- **Scheduled Actions**: Schedule follower actions at optimal times for maximum engagement
- **Mobile Responsive**: Access your dashboard from any device with our fully responsive design
- **Background Processing**: Robust background job system for reliable automation
- **Professional UI**: Modern, beautiful interface with excellent user experience

## 🚀 Quick Start

### Prerequisites

- Ruby 3.2.0 or higher
- SQLite3 (for development) or PostgreSQL (for production)
- Redis (for background jobs)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd infinity
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up environment variables**
   ```bash
   cp env.example .env
   # Edit .env with your configuration
   ```

4. **Set up the database**
   ```bash
   bundle exec rake db:create
   bundle exec rake db:migrate
   ```

5. **Start the application**
   ```bash
   # Start the web server
   bundle exec rackup
   
   # In another terminal, start the background worker
   bundle exec sidekiq -r ./app.rb
   ```

6. **Access the application**
   Open your browser and navigate to `http://localhost:4567`

## 🛠️ Configuration

### Environment Variables

Create a `.env` file with the following variables:

```env
# Application Settings
RACK_ENV=development
PORT=4567
SESSION_SECRET=your-super-secret-session-key-here

# Database
DATABASE_URL=sqlite3:///db/development.sqlite3

# JWT Secret
JWT_SECRET=your-super-secret-jwt-key-here

# Redis (for Sidekiq)
REDIS_URL=redis://localhost:6379/0

# Facebook API (optional)
FACEBOOK_APP_ID=your-facebook-app-id
FACEBOOK_APP_SECRET=your-facebook-app-secret

# Telegram Bot (optional)
TELEGRAM_BOT_TOKEN=your-telegram-bot-token
TELEGRAM_CHAT_ID=your-telegram-chat-id
```

## 🚀 Deployment

### Deploy to Render

1. **Create a new Web Service**
   - Connect your GitHub repository
   - Set the build command: `bundle install`
   - Set the start command: `bundle exec rackup config.ru -p $PORT`

2. **Add Environment Variables**
   - `RACK_ENV=production`
   - `DATABASE_URL` (Render will provide this)
   - `REDIS_URL` (Add a Redis instance)
   - `JWT_SECRET` (Generate a secure random string)
   - `SESSION_SECRET` (Generate a secure random string)

3. **Add a Background Worker**
   - Create a new Background Worker service
   - Set the start command: `bundle exec sidekiq -r ./app.rb`
   - Add the same environment variables

### Deploy to Heroku

1. **Create a new Heroku app**
   ```bash
   heroku create your-app-name
   ```

2. **Add add-ons**
   ```bash
   heroku addons:create heroku-postgresql
   heroku add-ons:create heroku-redis
   ```

3. **Set environment variables**
   ```bash
   heroku config:set RACK_ENV=production
   heroku config:set JWT_SECRET=your-secret-key
   heroku config:set SESSION_SECRET=your-session-secret
   ```

4. **Deploy**
   ```bash
   git push heroku main
   ```

## 📊 Usage

### 1. Create an Account
- Register with your email and password
- Verify your account

### 2. Add Facebook Accounts
- Navigate to "Facebook Accounts" tab
- Click "Add Account"
- Enter your Facebook credentials
- The system will authenticate and store your account securely

### 3. Configure Automation
- Go to "Automation" tab
- Set your target follower count
- Configure delays and daily limits
- Save your settings

### 4. Start Automation
- Select an account from the dashboard
- Click "Start" to begin the automation process
- Monitor progress in real-time

### 5. View Analytics
- Check the "Analytics" tab for detailed insights
- Monitor follower growth and activity patterns
- Track success rates and performance metrics

## 🔧 Development

### Project Structure

```
infinity/
├── app.rb                 # Main Sinatra application
├── config.ru             # Rack configuration
├── Gemfile               # Ruby dependencies
├── Procfile              # Deployment configuration
├── models/               # Database models
│   ├── user.rb
│   ├── facebook_account.rb
│   └── follower_log.rb
├── workers/              # Background job workers
│   └── follower_worker.rb
├── views/                # ERB templates
│   ├── index.erb
│   └── dashboard.erb
├── lib/                  # Custom libraries
│   ├── matematika.rb
│   ├── threadpool.rb
│   ├── files.rb
│   └── os.rb
├── db/                   # Database migrations
│   └── migrate/
└── public/               # Static assets
```

### Running Tests

```bash
bundle exec rspec
```

### Database Migrations

```bash
# Create a new migration
bundle exec rake db:create_migration NAME=migration_name

# Run migrations
bundle exec rake db:migrate

# Rollback migrations
bundle exec rake db:rollback
```

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: BCrypt password encryption
- **Rate Limiting**: Built-in protection against abuse
- **Account Isolation**: Each user's data is completely isolated
- **Secure Headers**: Protection against common web vulnerabilities
- **Input Validation**: Comprehensive input sanitization

## 📈 Monitoring

### Background Jobs
- Monitor Sidekiq dashboard for job status
- View job history and retry attempts
- Set up alerts for failed jobs

### Application Logs
- Check application logs for errors
- Monitor performance metrics
- Set up log aggregation

### Database Monitoring
- Monitor database performance
- Check for slow queries
- Set up database backups

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This tool is for educational and research purposes only. Users are responsible for complying with Facebook's Terms of Service and applicable laws. The developers are not responsible for any misuse of this software.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/your-repo/issues) page
2. Create a new issue with detailed information
3. Contact support at support@infinity.com

## 🔄 Updates

Stay updated with the latest features and improvements:

- Watch the repository for updates
- Follow our [blog](https://blog.infinity.com)
- Join our [Discord community](https://discord.gg/infinity)

---

**Made with ❤️ by the Infinity Team** 