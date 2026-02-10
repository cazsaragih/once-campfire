require "test_helper"

class CallsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! "once.campfire.test"
    sign_in :david
    @room = rooms(:designers)
  end

  test "create starts a new call and returns token JSON" do
    room = rooms(:watercooler) # no active call
    post room_calls_url(room)
    assert_response :success

    json = JSON.parse(response.body)
    assert json["token"].present?
    assert json["ws_url"].present?
    assert json["room_name"].present?
    assert json["call_id"].present?
  end

  test "create joins existing active call instead of creating new one" do
    assert_no_difference "Call.count" do
      post room_calls_url(@room)
    end
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal calls(:designers_active_call).id, json["call_id"]
  end

  test "create returns correct ws_url from config" do
    post room_calls_url(@room)
    json = JSON.parse(response.body)
    assert_equal Rails.configuration.x.livekit.ws_url, json["ws_url"]
  end

  test "destroy leaves the call" do
    call = calls(:designers_active_call)
    delete room_call_url(@room, call)
    assert_response :ok
    assert_not_nil call_participants(:david_in_designers_call).reload.left_at
  end

  test "destroy ends call when last participant leaves" do
    call = calls(:designers_active_call)
    delete room_call_url(@room, call)
    assert_response :ok
    assert call.reload.ended?
  end

  test "create leaves other active calls when joining a new one" do
    # David is already in designers_active_call via fixtures.
    # Create a new call in watercooler and join it.
    room = rooms(:watercooler)
    post room_calls_url(room)
    assert_response :success

    # David should have left the designers call
    assert_not_nil call_participants(:david_in_designers_call).reload.left_at
  end

  test "banner renders both join and leave buttons with stimulus targets" do
    get room_url(@room)
    assert_response :success
    assert_select "[data-call-banner-target='joinBtn']"
    assert_select "[data-call-banner-target='leaveBtn']"
  end

  test "room show page banner says mingle not huddle" do
    get room_url(@room)
    assert_response :success
    assert_select ".call-banner__label", text: /mingle/i
    assert_no_match(/huddle/i, response.body)
  end

  test "ended mingle banner shows ended text without live indicator" do
    call = calls(:designers_active_call)
    call.end!

    get room_url(@room)
    assert_response :success
    assert_select ".call-banner__content--ended"
    assert_select ".call-banner__label", text: /mingle has ended/i
    assert_select ".call-banner__live", count: 0
    assert_select "[data-call-banner-target='joinBtn']", count: 0
    assert_select "[data-call-banner-target='leaveBtn']", count: 0
  end

  test "ended mingle banner persists on page load" do
    call = calls(:designers_active_call)
    call.end!

    get room_url(@room)
    assert_response :success
    assert_select ".call-banner__content--ended", count: 1
  end

  test "room show page has mingle controller not huddle" do
    get room_url(@room)
    assert_response :success
    assert_select "[data-controller='mingle']"
    assert_no_match(/data-controller="huddle"/, response.body)
  end
end
