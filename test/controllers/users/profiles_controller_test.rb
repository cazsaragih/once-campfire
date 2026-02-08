require "test_helper"

class Users::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in :david
  end

  test "show" do
    get user_profile_url

    assert_response :success
  end

  test "update" do
    put user_profile_url, params: { user: { name: "John Doe", bio: "Acrobat" } }

    assert_redirected_to user_profile_url
    assert_equal "John Doe", users(:david).reload.name
    assert_equal "Acrobat", users(:david).bio
    assert_equal "david@37signals.com", users(:david).email_address
  end

  test "update availability to away" do
    put user_profile_url, params: { user: { availability: "away" } }

    assert_redirected_to user_profile_url
    assert_equal "away", users(:david).reload.availability
  end

  test "update availability to online" do
    users(:david).update!(availability: :away)

    put user_profile_url, params: { user: { availability: "online" } }

    assert_redirected_to user_profile_url
    assert_equal "online", users(:david).reload.availability
  end

  test "update availability preserves other attributes" do
    put user_profile_url, params: { user: { availability: "away" } }

    david = users(:david).reload
    assert_equal "away", david.availability
    assert_equal "David", david.name
    assert_equal "david@37signals.com", david.email_address
  end

  test "updates are limited to the current user" do
    put user_profile_url(users(:jason)), params: { user: { name: "John Doe" } }

    assert_equal "Jason", users(:jason).reload.name
  end
end
