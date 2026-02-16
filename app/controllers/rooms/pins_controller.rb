class Rooms::PinsController < ApplicationController
  include RoomScoped

  def index
    @pinned_messages = @room.messages.pinned
                            .preload(:pin, boosts: :booster)
                            .preload(creator: :avatar_attachment)
                            .preload(rich_text_body: { embeds_attachments: :blob })
                            .preload(attachment_attachment: :blob, attachment_blob: :variant_records)
                            .order("pins.created_at DESC")
  end
end
