require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  setup do
    @post = posts(:one)
    sign_in_as(users(:one))
  end

  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end

  test "should create post" do
    visit posts_url
    click_on "New post"

    fill_in "Content", with: @post.content
    click_on "Create Post"

    assert_text "Post was successfully created"
    click_on "Back"
  end

  test "should update Post" do
    visit post_url(@post)
    click_on "Edit", match: :first

    fill_in "Content", with: @post.content
    click_on "Update Post"

    assert_text "Post was successfully updated"
    click_on "Back"
  end

  test "should destroy Post" do
    visit post_url(@post)
    click_on "Delete", match: :first

    assert_text "Post was successfully destroyed"
  end

  private

  def sign_in_as(user)
    visit new_user_session_url
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Log in"
  end
end
