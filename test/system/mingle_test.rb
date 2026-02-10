require "application_system_test_case"

class MingleTest < ApplicationSystemTestCase
  setup do
    sign_in "jz@37signals.com"
  end

  test "mingle banner visible in room with messages" do
    room = rooms(:designers)
    call = room.calls.create!(initiator: users(:jz), started_at: Time.current)
    call.join(users(:jz))

    join_room room
    assert_selector ".call-banner__content", text: "A mingle is happening"
  end

  test "mingle banner visible in empty room" do
    room = rooms(:hq)
    call = room.calls.create!(initiator: users(:jz), started_at: Time.current)
    call.join(users(:jz))

    join_room room
    assert_selector ".call-banner__content", text: "A mingle is happening"
  end

  test "ended mingle banner shows ended text" do
    room = rooms(:designers)
    call = room.calls.create!(initiator: users(:jz), started_at: 5.minutes.ago)
    call.join(users(:jz))
    call.end!

    join_room room
    assert_selector ".call-banner__content--ended", text: "A mingle has ended"
    assert_no_selector ".call-banner__live"
  end

  test "headphones button uses mingle controller" do
    join_room rooms(:designers)
    assert_selector "[data-controller='mingle']"
  end
end
