require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @profile = profiles(:one)
    sign_in users(:one)
  end

  test "requires authentication" do
    sign_out users(:one)

    get profiles_url

    assert_redirected_to new_user_session_url
  end

  test "should get index" do
    get profiles_url
    assert_response :success
  end

  test "should get new" do
    get new_profile_url
    assert_response :success
  end

  test "should create profile" do
    assert_difference("Profile.count") do
      post profiles_url, params: { profile: { bio: @profile.bio, name: @profile.name, role: @profile.role, user_id: users(:two).id } }
    end

    assert_redirected_to profile_url(Profile.last)
    assert_equal users(:one), Profile.last.user
  end

  test "should show profile" do
    get profile_url(@profile)
    assert_response :success
  end

  test "should get edit" do
    get edit_profile_url(@profile)
    assert_response :success
  end

  test "cannot edit another user's profile" do
    get edit_profile_url(profiles(:two))

    assert_response :not_found
  end

  test "should update profile" do
    patch profile_url(@profile), params: { profile: { bio: @profile.bio, name: "Updated name", role: @profile.role, user_id: users(:two).id } }
    assert_redirected_to profile_url(@profile)
    assert_equal "Updated name", @profile.reload.name
    assert_equal users(:one), @profile.user
  end

  test "cannot update another user's profile" do
    patch profile_url(profiles(:two)), params: { profile: { name: "Changed name" } }

    assert_response :not_found
    assert_not_equal "Changed name", profiles(:two).reload.name
  end

  test "should destroy profile" do
    assert_difference("Profile.count", -1) do
      delete profile_url(@profile)
    end

    assert_redirected_to profiles_url
  end

  test "cannot destroy another user's profile" do
    assert_no_difference("Profile.count") do
      delete profile_url(profiles(:two))
    end

    assert_response :not_found
  end
end
