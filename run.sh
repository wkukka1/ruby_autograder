# run.sh
#!/usr/bin/env bash
set -e

# Load env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Ensure latest migrations
bundle exec rails db:migrate

# (Re)start Sidekiq in foreground
bundle exec sidekiq -L log/sidekiq.log &

# Launch Rails server
bundle exec rails s -b 0.0.0.0 -p 3000
