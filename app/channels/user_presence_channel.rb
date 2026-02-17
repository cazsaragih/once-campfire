class UserPresenceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "availability_updates"

    current_user.mark_connected
  end

  def unsubscribed
    current_user.mark_disconnected
  end

  def heartbeat
    current_user.refresh_presence
    User.sweep_stale_presence if rand < 0.1
  end
end
