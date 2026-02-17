class UserPresenceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "availability_updates"

    @visible = params[:visible] != false
    current_user.mark_visible if @visible
  end

  def unsubscribed
    current_user.mark_hidden if @visible
  end

  def visible
    unless @visible
      @visible = true
      current_user.mark_visible
    end
  end

  def hidden
    if @visible
      @visible = false
      current_user.mark_hidden
    end
  end

  def heartbeat
    current_user.refresh_presence
    User.sweep_stale_presence if rand < 0.1
  end
end
