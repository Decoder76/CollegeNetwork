require "application_system_test_case"

class ConversationsTest < ApplicationSystemTestCase
  setup do
    sign_in_as(users(:one))
  end

  test "starts a conversation and sends a private message" do
    visit conversations_url
    click_on "Start a conversation"
    select users(:two).name, from: "Start with"
    click_on "Start conversation"

    assert_text users(:one).name
    assert_text users(:two).name

    fill_in "Write a message", with: "Hello from the college network"
    click_on "Send message"

    assert_text "Hello from the college network"
  end

  private

  def sign_in_as(user)
    visit new_user_session_url
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Log in"
  end
end
