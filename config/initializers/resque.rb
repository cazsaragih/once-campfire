# Configure Resque to use Redis
# Supports both local Redis (redis://localhost:6379) and managed Redis via REDIS_URL env var
Resque.redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379"))
