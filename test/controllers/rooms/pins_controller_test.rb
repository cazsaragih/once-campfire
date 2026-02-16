require "test_helper"

class Rooms::PinsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in :david
  end

  test "index shows pinned messages" do
    room = rooms(:designers)

    get room_pins_url(room)
    assert_response :success
    assert_select ".messages .message", count: 1
  end

  test "index with no pins shows empty state" do
    room = rooms(:watercooler)
    room.pins.destroy_all

    get room_pins_url(room)
    assert_response :success
  end
end
