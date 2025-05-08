# Rails Gemini Autograder

## Setup

1. Clone repo
2. `bundle install`
3. Create `.env` with:
   ```
   GEMINI_API_KEY=your_api_key
   GEMINI_API_URL=https://gemini.googleapis.com
   REDIS_URL=redis://localhost:6379/1
   ```
4. `rails db:create db:migrate`
5. Start Redis: `redis-server`
6. Start Sidekiq: `bundle exec sidekiq`
7. Start Rails: `rails s`

## Usage

- **POST** `/submissions` with JSON body:
  ```json
  {
    "content": "Your submission text or code...",
    "assignment_type": "text"  // or "code", "math"
  }
  ```
- **GET** `/submissions/:id` to fetch status & feedback

```bash
curl -X POST http://localhost:3000/submissions \
  -H "Content-Type: application/json" \
  -d '{"content":"2+2=4","assignment_type":"math"}'
```
