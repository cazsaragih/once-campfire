class Messages::PinsController < ApplicationController
  before_action :set_message

  def create
    @pin = @message.create_pin!(creator: Current.user)
    broadcast_pin_change

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to room_path(@message.room) }
    end
  end

  def destroy
    @message.pin&.destroy!
    @message.reload
    broadcast_pin_change

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to room_path(@message.room) }
    end
  end

  private
    def set_message
      @message = Current.user.reachable_messages.find(params[:message_id])
    end

    def broadcast_pin_change
      @message.broadcast_replace_to @message.room, :messages,
        target: dom_id(@message, :pin_indicator),
        partial: "messages/pins/indicator",
        locals: { message: @message },
        attributes: { maintain_scroll: true }
    end
end
