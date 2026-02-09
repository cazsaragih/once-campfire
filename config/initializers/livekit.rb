Rails.application.configure do
  config.x.livekit.api_key    = ENV.fetch("LIVEKIT_API_KEY", "devkey")
  config.x.livekit.api_secret = ENV.fetch("LIVEKIT_API_SECRET", "devsecret")
  config.x.livekit.ws_url     = ENV.fetch("LIVEKIT_WS_URL", "ws://localhost:7880")
  config.x.livekit.http_url   = ENV.fetch("LIVEKIT_HTTP_URL", "http://localhost:7880")
end
