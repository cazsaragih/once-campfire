require "test_helper"

class CallParticipantTest < ActiveSupport::TestCase
  test "belongs to call" do
    assert_equal calls(:designers_active_call), call_participants(:david_in_designers_call).call
  end

  test "belongs to user" do
    assert_equal users(:david), call_participants(:david_in_designers_call).user
  end
end
