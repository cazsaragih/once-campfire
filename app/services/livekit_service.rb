class LivekitService
  def initialize
    @api_key    = Rails.configuration.x.livekit.api_key
    @api_secret = Rails.configuration.x.livekit.api_secret
    @http_url   = Rails.configuration.x.livekit.http_url
  end

  def access_token(user:, room_name:)
    token = LiveKit::AccessToken.new(api_key: @api_key, api_secret: @api_secret)
    token.identity = user.id.to_s
    token.name = user.name
    token.video_grant = LiveKit::VideoGrant.new(
      roomJoin: true,
      room: room_name,
      canPublish: true,
      canSubscribe: true
    )
    token.to_jwt
  end

  def verify_webhook(body, auth_header)
    token_verifier = LiveKit::TokenVerifier.new(api_key: @api_key, api_secret: @api_secret)
    token_verifier.verify(auth_header)
    JSON.parse(body)
  rescue => e
    Rails.logger.warn "LiveKit webhook verification failed: #{e.message}"
    nil
  end

  def delete_room(room_name)
    room_service = LiveKit::RoomServiceClient.new(@http_url, @api_key, @api_secret)
    room_service.delete_room(room_name)
  rescue => e
    Rails.logger.warn "Failed to delete LiveKit room #{room_name}: #{e.message}"
  end
end
