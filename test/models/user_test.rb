require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "is valid with a name, email, password, and role" do
    assert users(:one).valid?
  end

  test "requires a name" do
    user = users(:one)
    user.name = nil

    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "supports the defined roles" do
    assert_equal "student", users(:one).role
    assert_equal "faculty", users(:two).role
  end
end
