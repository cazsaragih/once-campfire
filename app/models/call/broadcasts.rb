module Call::Broadcasts
  extend ActiveSupport::Concern

  def broadcast_call_started
    broadcast_replace_to room, :messages,
      target: "call_banner_#{room_id}",
      partial: "calls/banner",
      locals: { call: self, room: room }
  end

  def broadcast_call_updated
    broadcast_replace_to room, :messages,
      target: "call_banner_#{room_id}",
      partial: "calls/banner",
      locals: { call: self, room: room }
  end

  def broadcast_call_ended
    broadcast_replace_to room, :messages,
      target: "call_banner_#{room_id}",
      partial: "calls/banner",
      locals: { call: nil, room: room }
  end
end
