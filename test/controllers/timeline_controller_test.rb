require "test_helper"

class TimelineControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get timeline_index_url
    assert_response :success
  end

  test "should get gantt" do
    get timeline_gantt_url
    assert_response :success
  end

  test "should get milestones" do
    get timeline_milestones_url
    assert_response :success
  end
end
