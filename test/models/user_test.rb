require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "is valid with an email and a password" do
    assert User.new(email: "new@example.com", password: "password123").valid?
  end

  test "requires an email" do
    user = User.new(password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "requires a unique email, ignoring case" do
    user = User.new(email: users(:one).email.upcase, password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "requires a password of at least 6 characters" do
    user = User.new(email: "new@example.com", password: "short")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
  end
end
