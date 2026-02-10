class Call < ApplicationRecord
  include Broadcasts

  belongs_to :room
  belongs_to :initiator, class_name: "User"
  has_many :call_participants, dependent: :destroy
  has_many :active_participants, -> { where(left_at: nil) }, class_name: "CallParticipant"
  has_many :users, through: :active_participants, source: :user

  scope :active, -> { where(status: "active") }

  before_create -> { self.livekit_room_name ||= "room-#{room_id}-#{SecureRandom.hex(8)}" }
  before_create -> { self.started_at ||= Time.current }

  def end!
    update!(status: "ended", ended_at: Time.current)
    active_participants.update_all(left_at: Time.current)
    broadcast_call_ended
    LivekitService.new.delete_room(livekit_room_name)
  end

  def active?
    status == "active"
  end

  def ended?
    status == "ended"
  end

  def participant_for(user)
    active_participants.find_by(user: user)
  end

  def includes_user?(user)
    active_participants.exists?(user: user)
  end

  def join(user)
    leave_other_active_calls(user)
    call_participants.create!(user: user, joined_at: Time.current) unless includes_user?(user)
    broadcast_call_updated
  end

  def leave(user)
    participant_for(user)&.update!(left_at: Time.current)
    if active_participants.reload.none?
      end!
    else
      broadcast_call_updated
    end
  end

  private
    def leave_other_active_calls(user)
      CallParticipant.where(user: user, left_at: nil).where.not(call: self).find_each do |cp|
        cp.call.leave(user)
      end
    end
end
