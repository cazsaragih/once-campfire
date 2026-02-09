require "test_helper"

class CallTest < ActiveSupport::TestCase
  test "generates livekit_room_name on create" do
    call = rooms(:watercooler).calls.create!(initiator: users(:david))
    assert_match /\Aroom-\d+-[a-f0-9]{16}\z/, call.livekit_room_name
  end

  test "sets started_at on create" do
    call = rooms(:watercooler).calls.create!(initiator: users(:david))
    assert_not_nil call.started_at
  end

  test "active scope returns only active calls" do
    assert_includes Call.active, calls(:designers_active_call)
    assert_not_includes Call.active, calls(:designers_ended_call)
  end

  test "room active_call returns last active call" do
    assert_equal calls(:designers_active_call), rooms(:designers).active_call
    assert_nil rooms(:watercooler).active_call
  end

  test "join adds participant" do
    call = calls(:designers_active_call)
    call.join(users(:jason))
    assert call.includes_user?(users(:jason))
  end

  test "join is idempotent" do
    call = calls(:designers_active_call)
    assert_no_difference "CallParticipant.count" do
      call.join(users(:david))
    end
  end

  test "leave marks participant left_at" do
    call = calls(:designers_active_call)
    call.leave(users(:david))
    assert_not_nil call_participants(:david_in_designers_call).reload.left_at
  end

  test "leave ends call when last participant leaves" do
    call = calls(:designers_active_call)
    call.leave(users(:david))
    assert call.reload.ended?
    assert_not_nil call.ended_at
  end

  test "leave does not end call when other participants remain" do
    call = calls(:designers_active_call)
    call.join(users(:jason))
    call.leave(users(:david))
    assert call.reload.active?
  end

  test "end! marks call as ended and all participants left" do
    call = calls(:designers_active_call)
    call.end!
    assert_equal "ended", call.status
    assert call_participants(:david_in_designers_call).reload.left_at.present?
  end
end
