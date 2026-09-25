require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "redirects signed-out visitors to the sign-in page" do
    [ root_url, to_do_items_url, categories_url, new_to_do_item_url ].each do |url|
      get url
      assert_redirected_to new_user_session_url
    end
  end

  test "returns 401 for signed-out JSON requests" do
    get to_do_items_url(format: :json)
    assert_response :unauthorized
  end

  test "renders the sign-in and sign-up pages without a session" do
    get new_user_session_url
    assert_response :success

    get new_user_registration_url
    assert_response :success
  end

  test "signs in with valid credentials" do
    post user_session_url, params: { user: { email: users(:one).email, password: "password123" } }
    assert_redirected_to root_url

    get root_url
    assert_response :success
  end

  test "rejects an invalid password" do
    post user_session_url, params: { user: { email: users(:one).email, password: "wrong-password" } }
    assert_response :unprocessable_content

    get root_url
    assert_redirected_to new_user_session_url
  end

  test "signs up a new user and signs them in" do
    assert_difference("User.count", 1) do
      post user_registration_url, params: { user: { email: "new@example.com", password: "password123", password_confirmation: "password123" } }
    end
    assert_redirected_to root_url

    get root_url
    assert_response :success
  end

  test "signing out returns to the sign-in page" do
    sign_in users(:one)

    delete destroy_user_session_url
    assert_redirected_to new_user_session_url

    get root_url
    assert_redirected_to new_user_session_url
  end
end
