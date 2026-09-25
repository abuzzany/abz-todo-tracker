require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "signing up, logging out, and logging back in" do
    visit root_url
    assert_selector "h1", text: "Log in"
    assert_text "You need to sign in or sign up before continuing."

    click_on "Sign up"
    assert_selector "h1", text: "Sign up"
    fill_in "Email", with: "new@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    click_on "Sign up"

    assert_selector "h1", text: "Dashboard"
    assert_text "new@example.com"

    click_on "Log out"
    assert_selector "h1", text: "Log in"
    assert_text "Signed out successfully."

    fill_in "Email", with: "new@example.com"
    fill_in "Password", with: "password123"
    click_on "Log in"

    assert_selector "h1", text: "Dashboard"
  end

  test "showing an error for a wrong password" do
    visit new_user_session_url
    fill_in "Email", with: users(:one).email
    fill_in "Password", with: "wrong-password"
    click_on "Log in"

    assert_selector "h1", text: "Log in"
    assert_text "Invalid email or password."
  end
end
