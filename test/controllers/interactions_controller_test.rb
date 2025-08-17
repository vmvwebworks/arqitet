require "test_helper"

class InteractionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get interactions_new_url
    assert_response :success
  end

  test "should get create" do
    get interactions_create_url
    assert_response :success
  end

  test "should get edit" do
    get interactions_edit_url
    assert_response :success
  end

  test "should get update" do
    get interactions_update_url
    assert_response :success
  end

  test "should get destroy" do
    get interactions_destroy_url
    assert_response :success
  end
end
