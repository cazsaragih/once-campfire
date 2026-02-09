class CallsController < ApplicationController
  include RoomScoped

  def create
    @call = @room.active_call || create_call

    token = join_call(@call)

    render json: {
      token: token,
      ws_url: Rails.configuration.x.livekit.ws_url,
      room_name: @call.livekit_room_name,
      call_id: @call.id
    }
  end

  def destroy
    @call = @room.calls.find(params[:id])
    @call.leave(Current.user)

    head :ok
  end

  private
    def create_call
      call = @room.calls.create!(initiator: Current.user)
      call.broadcast_call_started
      call
    end

    def join_call(call)
      call.join(Current.user)
      LivekitService.new.access_token(user: Current.user, room_name: call.livekit_room_name)
    end
end
