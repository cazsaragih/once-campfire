require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user does not prevent very long passwords" do
    users(:david).update(password: "secret" * 50)
    assert users(:david).valid?
  end

  test "creating users grants membership to the open rooms" do
    assert_difference -> { Membership.count }, +Rooms::Open.count do
      create_new_user
    end
  end

  test "deactivating a user deletes push subscriptions, searches, memberships for non-direct rooms, and changes their email address" do
    assert_difference -> { Membership.count }, -users(:david).memberships.without_direct_rooms.count do
    assert_difference -> { Push::Subscription.count }, -users(:david).push_subscriptions.count do
    assert_difference -> { Search.count }, -users(:david).searches.count do
      SecureRandom.stubs(:uuid).returns("2e7de450-cf04-4fa8-9b02-ff5ab2d733e7")
      users(:david).deactivate
      assert_equal "david-deactivated-2e7de450-cf04-4fa8-9b02-ff5ab2d733e7@37signals.com", users(:david).reload.email_address
    end
    end
    end
  end

  test "availability defaults to online" do
    user = create_new_user
    assert_equal "online", user.availability
    assert user.online?
    assert_not user.away?
  end

  test "availability can be set to away" do
    user = users(:david)
    user.update!(availability: :away)
    assert user.reload.away?
    assert_not user.online?
  end

  test "changing availability broadcasts update" do
    user = users(:david)

    assert_difference -> { ActionCable.server.pubsub.broadcasts("availability_updates").size }, 1 do
      user.update!(availability: :away)
    end
  end

  test "changing availability broadcasts user id and new state" do
    user = users(:david)
    user.update!(availability: :away)

    message = ActionCable.server.pubsub.broadcasts("availability_updates").last
    parsed = JSON.parse(message)
    assert_equal user.id, parsed["userId"]
    assert_equal "away", parsed["availability"]
  end

  test "updating other attributes does not broadcast availability" do
    assert_no_difference -> { ActionCable.server.pubsub.broadcasts("availability_updates").size } do
      users(:david).update!(name: "Dave")
    end
  end

  test "deactivating a user deletes their sessions" do
    assert_changes -> { users(:david).sessions.count }, from: 1, to: 0 do
      users(:david).deactivate
    end
  end

  private
    def create_new_user
      User.create!(name: "User", email_address: "user@example.com", password: "secret123456")
    end
end
