Rails.application.configure do
  config.x.livekit.api_key    = ENV.fetch("LIVEKIT_API_KEY", "devkey")
  config.x.livekit.api_secret = ENV.fetch("LIVEKIT_API_SECRET", "devsecret")

  livekit_url = ENV.fetch("LIVEKIT_URL", "ws://localhost:7880")
  config.x.livekit.ws_url   = livekit_url
  config.x.livekit.http_url = livekit_url.sub(%r{\Awss://}, "https://").sub(%r{\Aws://}, "http://")
end
