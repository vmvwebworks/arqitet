require "test_helper"

class SubscriptionPlansControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get subscription_plans_index_url
    assert_response :success
  end

  test "should get show" do
    get subscription_plans_show_url
    assert_response :success
  end
end
