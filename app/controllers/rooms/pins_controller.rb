class Rooms::PinsController < ApplicationController
  include RoomScoped

  def index
    @pinned_messages = @room.messages.pinned.with_creator.with_attachment_details.with_boosts.with_pin
                            .order("pins.created_at DESC")
  end
end
