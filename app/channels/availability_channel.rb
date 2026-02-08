class AvailabilityChannel < ApplicationCable::Channel
  def subscribed
    stream_from "availability_updates"
  end
end
