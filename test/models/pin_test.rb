require "test_helper"

class PinTest < ActiveSupport::TestCase
  test "message can only be pinned once" do
    assert_raises(ActiveRecord::RecordInvalid) do
      Pin.create!(message: messages(:first), creator: users(:jason))
    end
  end

  test "pinned scope returns pinned messages" do
    assert_includes Message.pinned, messages(:first)
    assert_not_includes Message.pinned, messages(:second)
  end

  test "destroying pin touches message" do
    message = messages(:first)
    original_updated_at = message.updated_at

    travel 1.second do
      message.pin.destroy!
      assert_operator message.reload.updated_at, :>, original_updated_at
    end
  end
end
