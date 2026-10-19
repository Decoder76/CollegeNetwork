require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @conversation = conversations(:one)
    sign_in users(:one)
  end

  test "requires authentication to list conversations" do
    sign_out users(:one)

    get conversations_url

    assert_redirected_to new_user_session_url
  end

  test "only participants can view a conversation" do
    sign_out users(:one)
    sign_in users(:three)

    get conversation_url(@conversation)

    assert_response :not_found
  end

  test "starts a private conversation with another user" do
    assert_difference("Conversation.count") do
      post conversations_url, params: { conversation: { recipient_id: users(:three).id } }
    end

    conversation = Conversation.last
    assert_redirected_to conversation_url(conversation)
    assert conversation.active_member?(users(:one))
    assert conversation.active_member?(users(:three))
  end

  test "sends a message as the signed-in participant" do
    assert_difference("Message.count") do
      post conversation_messages_url(@conversation), params: { message: { content: "Hello privately" } }
    end

    assert_redirected_to conversation_url(@conversation)
    assert_equal users(:one), Message.last.sender
    assert_equal @conversation, Message.last.conversation
  end

  test "a participant cannot edit another participant's message" do
    sign_out users(:one)
    sign_in users(:two)

    patch conversation_message_url(@conversation, messages(:one)), params: { message: { content: "Changed" } }

    assert_response :not_found
    assert_equal "MyText", messages(:one).reload.content
  end

  test "the invited user joins only after owner approval and their acceptance" do
    sign_out users(:one)
    sign_in users(:two)
    post conversation_invitations_url(@conversation), params: { invitee_id: users(:three).id }
    invitation = ConversationInvitation.last
    assert_equal "pending_approval", invitation.status

    sign_out users(:two)
    sign_in users(:one)
    patch conversation_invitation_url(@conversation, invitation), params: { decision: "approve" }
    assert_equal "pending_acceptance", invitation.reload.status

    sign_out users(:one)
    sign_in users(:three)
    get conversation_url(@conversation)
    assert_response :not_found

    patch respond_to_invitation_url(invitation), params: { decision: "accept" }

    assert_redirected_to conversation_url(@conversation)
    assert @conversation.reload.active_member?(users(:three))
    assert users(:two).connected_with?(users(:three))
  end

  test "an inviter must approve a participant's request to leave" do
    invitation = @conversation.invitations.create!(
      invited_by: users(:two),
      invitee: users(:three),
      status: "accepted",
      approved_at: Time.current,
      accepted_at: Time.current
    )
    @conversation.participants.create!(user: users(:three), joined_at: Time.current)

    sign_out users(:one)
    sign_in users(:three)
    post conversation_leave_requests_url(@conversation)
    leave_request = ConversationLeaveRequest.last
    assert_equal users(:two), leave_request.approver

    sign_out users(:three)
    sign_in users(:two)
    patch conversation_leave_request_url(@conversation, leave_request), params: { decision: "approve" }

    assert_equal "approved", leave_request.reload.status
    assert_not @conversation.reload.active_member?(users(:three))
    assert users(:two).connected_with?(users(:three))
  end
end
