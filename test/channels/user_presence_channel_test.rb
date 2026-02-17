require "test_helper"

class UserPresenceChannelTest < ActionCable::Channel::TestCase
  setup do
    @user = users(:david)
    @user.update_columns(active_connections: 0, availability: 0, manually_away: false)
    stub_connection(current_user: @user)
  end

  test "subscribes and streams from availability_updates" do
    subscribe

    assert subscription.confirmed?
    assert_has_stream "availability_updates"
  end

  test "subscribing marks user as connected and online" do
    subscribe

    @user.reload
    assert_equal 1, @user.active_connections
    assert @user.online?
  end

  test "unsubscribing marks user as disconnected and away" do
    subscribe

    unsubscribe

    @user.reload
    assert_equal 0, @user.active_connections
    assert @user.away?
  end

  test "multiple subscriptions increment connections" do
    subscribe

    # Simulate a second tab by directly calling mark_connected
    @user.mark_connected

    @user.reload
    assert_equal 2, @user.active_connections
  end

  test "unsubscribing with other connections keeps user online" do
    # Simulate two tabs
    @user.mark_connected
    subscribe

    unsubscribe

    @user.reload
    assert_equal 1, @user.active_connections
    assert @user.online?
  end

  test "manually away user is not set online on subscribe" do
    @user.update_columns(manually_away: true, availability: 1)

    subscribe

    @user.reload
    assert_equal 1, @user.active_connections
    assert @user.away?
  end

  test "heartbeat refreshes last_active_at" do
    subscribe

    @user.update_column(:last_active_at, 10.minutes.ago)

    perform :heartbeat

    @user.reload
    assert @user.last_active_at > 1.minute.ago
  end
end
