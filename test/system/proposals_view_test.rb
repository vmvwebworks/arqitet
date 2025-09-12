require "application_system_test_case"

class ProposalsViewTest < ApplicationSystemTestCase
  setup do
    @project = projects(:one)
    @slot = @project.project_slots.first
    sign_in_user
  end

  test "muestra la vista de propuestas" do
    visit proposals_project_project_slot_path(@project, @slot)
  assert_selector("h2", text: /Propuestas|Mapa de slots/)
  end
end
