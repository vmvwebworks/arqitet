require "application_system_test_case"

class ProjectsViewTest < ApplicationSystemTestCase
  setup do
    @project = projects(:one)
    sign_in_user
  end

  test "muestra la vista de proyectos" do
    visit projects_path
    assert_selector "h1", text: /Proyectos/
    assert_text @project.title
  end
end