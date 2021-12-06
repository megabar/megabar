require "test_helper"

class MegaBar::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get mega_bar_sessions_new_url
    assert_response :success
  end
end
