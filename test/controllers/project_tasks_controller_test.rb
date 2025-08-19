require "test_helper"

class ProjectTasksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get project_tasks_index_url
    assert_response :success
  end

  test "should get show" do
    get project_tasks_show_url
    assert_response :success
  end

  test "should get new" do
    get project_tasks_new_url
    assert_response :success
  end

  test "should get create" do
    get project_tasks_create_url
    assert_response :success
  end

  test "should get edit" do
    get project_tasks_edit_url
    assert_response :success
  end

  test "should get update" do
    get project_tasks_update_url
    assert_response :success
  end

  test "should get destroy" do
    get project_tasks_destroy_url
    assert_response :success
  end
end
