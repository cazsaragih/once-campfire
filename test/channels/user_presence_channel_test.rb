require "test_helper"

class UserPresenceChannelTest < ActionCable::Channel::TestCase
  setup do
    @user = users(:david)
    @user.update_columns(active_connections: 0, availability: 0, manually_away: false)
    stub_connection(current_user: @user)
  end

  test "subscribes and streams from availability_updates" do
    subscribe visible: true

    assert subscription.confirmed?
    assert_has_stream "availability_updates"
  end

  test "subscribing with visible tab marks user active" do
    subscribe visible: true

    @user.reload
    assert_equal 1, @user.active_connections
    assert @user.online?
  end

  test "subscribing with hidden tab does not increment connections" do
    subscribe visible: false

    @user.reload
    assert_equal 0, @user.active_connections
  end

  test "visible action increments connections and sets online" do
    subscribe visible: false

    perform :visible

    @user.reload
    assert_equal 1, @user.active_connections
    assert @user.online?
  end

  test "hidden action decrements connections and sets away" do
    subscribe visible: true

    perform :hidden

    @user.reload
    assert_equal 0, @user.active_connections
    assert @user.away?
  end

  test "double visible does not double count" do
    subscribe visible: true

    perform :visible

    @user.reload
    assert_equal 1, @user.active_connections
  end

  test "double hidden does not double decrement" do
    subscribe visible: false

    perform :hidden

    @user.reload
    assert_equal 0, @user.active_connections
  end

  test "unsubscribing decrements if visible" do
    subscribe visible: true

    unsubscribe

    @user.reload
    assert_equal 0, @user.active_connections
    assert @user.away?
  end

  test "unsubscribing does not decrement if hidden" do
    subscribe visible: false

    unsubscribe

    @user.reload
    assert_equal 0, @user.active_connections
  end

  test "manually away user is not set online on visible" do
    @user.update_columns(manually_away: true, availability: 1)

    subscribe visible: true

    @user.reload
    assert_equal 1, @user.active_connections
    assert @user.away?
  end

  test "heartbeat refreshes last_active_at" do
    subscribe visible: true

    @user.update_column(:last_active_at, 10.minutes.ago)

    perform :heartbeat

    @user.reload
    assert @user.last_active_at > 1.minute.ago
  end
end
