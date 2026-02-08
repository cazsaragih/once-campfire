require "test_helper"

class AvailabilityChannelTest < ActionCable::Channel::TestCase
  setup do
    stub_connection(current_user: users(:david))
  end

  test "subscribes" do
    subscribe

    assert subscription.confirmed?
  end

  test "streams from availability_updates" do
    subscribe

    assert_has_stream "availability_updates"
  end
end
