class LivekitWebhooksController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token

  def create
    event = LivekitService.new.verify_webhook(request.body.read, request.headers["Authorization"])
    return head :unauthorized unless event

    case event["event"]
    when "room_finished"
      handle_room_finished(event)
    when "participant_left"
      handle_participant_left(event)
    end

    head :ok
  end

  private
    def handle_room_finished(event)
      room_name = event.dig("room", "name")
      call = Call.find_by(livekit_room_name: room_name)
      call&.end! if call&.active?
    end

    def handle_participant_left(event)
      room_name = event.dig("room", "name")
      call = Call.find_by(livekit_room_name: room_name)
      return unless call&.active?

      identity = event.dig("participant", "identity")
      user = User.find_by(id: identity)
      call.leave(user) if user && call.includes_user?(user)
    end
end
