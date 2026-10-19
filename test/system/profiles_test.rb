require "application_system_test_case"

class ProfilesTest < ApplicationSystemTestCase
  setup do
    @profile = profiles(:one)
    sign_in_as(users(:one))
  end

  test "visiting the index" do
    visit profiles_url
    assert_selector "h1", text: "Profiles"
  end

  test "should create profile" do
    visit profiles_url
    click_on "New profile"

    fill_in "Bio", with: @profile.bio
    fill_in "Name", with: @profile.name
    select "Faculty", from: "Role"
    click_on "Create Profile"

    assert_text "Profile was successfully created"
    click_on "Back"
  end

  test "should update Profile" do
    visit profile_url(@profile)
    click_on "Edit", match: :first

    fill_in "Bio", with: @profile.bio
    fill_in "Name", with: @profile.name
    select "Faculty", from: "Role"
    click_on "Update Profile"

    assert_text "Profile was successfully updated"
    click_on "Back"
  end

  test "should destroy Profile" do
    visit profile_url(@profile)
    click_on "Delete", match: :first

    assert_text "Profile was successfully destroyed"
  end

  private

  def sign_in_as(user)
    visit new_user_session_url
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Log in"
  end
end
