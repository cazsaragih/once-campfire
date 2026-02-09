class Call::CleanupJob < ApplicationJob
  def perform
    Call.active.where(started_at: ...24.hours.ago).find_each do |call|
      call.end!
      LivekitService.new.delete_room(call.livekit_room_name)
    end
  end
end
