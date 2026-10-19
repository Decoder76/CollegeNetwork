require "test_helper"

class ConnectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "requires authentication" do
    sign_out users(:one)

    get connections_url

    assert_redirected_to new_user_session_url
  end

  test "creates and accepts a network connection" do
    assert_difference("NetworkConnection.count") do
      post connections_url, params: { recipient_id: users(:two).id }
    end
    request = NetworkConnection.last
    assert_equal "pending", request.status

    sign_out users(:one)
    sign_in users(:two)
    patch connection_url(request), params: { decision: "accept" }

    assert_equal "accepted", request.reload.status
    assert users(:one).connected_with?(users(:two))
  end

  test "removing a network connection does not remove conversation membership" do
    connection = network_connections(:one)
    conversations(:one).participants.create!(user: users(:three), joined_at: Time.current)

    assert_difference("NetworkConnection.count", -1) do
      delete connection_url(connection)
    end

    assert_not users(:two).connected_with?(users(:three))
    assert conversations(:one).active_member?(users(:three))
  end
end
