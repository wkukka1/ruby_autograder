# startup.sh
#!/usr/bin/env bash
set -e

# 1. Load environment vars from .env (if present)
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# 2. Install gems
echo "→ bundle install"
bundle install

# 3. Start Redis (daemonized)
echo "→ starting redis"
redis-server --daemonize yes

# 4. Create & migrate database
echo "→ rails db:create db:migrate"
bundle exec rails db:create db:migrate

# 5. Start Sidekiq (in background, logging to log/sidekiq.log)
echo "→ starting sidekiq"
bundle exec sidekiq -L log/sidekiq.log &

# 6. Start Rails server
echo "→ starting rails server on port 3000"
bundle exec rails s -b 0.0.0.0 -p 3000
