class Rooms::PinsController < ApplicationController
  include RoomScoped

  def index
    @pinned_messages = @room.messages.pinned.preload(:pin).with_creator.with_attachment_details.with_boosts
                            .order("pins.created_at DESC")
  end
end
