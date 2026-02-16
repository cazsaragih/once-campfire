require "test_helper"

class Messages::PinsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in :david
  end

  test "create pins a message" do
    message = messages(:second)

    assert_turbo_stream_broadcasts [ message.room, :messages ], count: 1 do
      assert_difference -> { Pin.count }, 1 do
        post message_pin_url(message, format: :turbo_stream)
        assert_response :success
      end
    end

    assert message.reload.pin.present?
  end

  test "destroy unpins a message" do
    message = messages(:first)

    assert_turbo_stream_broadcasts [ message.room, :messages ], count: 1 do
      assert_difference -> { Pin.count }, -1 do
        delete message_pin_url(message, format: :turbo_stream)
        assert_response :success
      end
    end

    assert_nil message.reload.pin
  end
end
