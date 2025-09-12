require "application_system_test_case"

class SlotsAssignmentTest < ApplicationSystemTestCase
  setup do
    @project = projects(:one)
    @user = users(:one)
    sign_in_user(@user)
  end

  test "visualiza el mapa de slots" do
    visit project_path(@project)
    # Si el proyecto tiene slots, debería mostrar el mapa
    if @project.project_slots.any?
      assert_selector "h2", text: /Mapa de Slots Profesionales/
      assert_selector ".slot-card", minimum: 1
    else
      assert_text "No hay slots profesionales definidos"
    end
  end

  test "abre y cierra el panel de búsqueda de usuarios" do
    visit project_path(@project)
  skip 'Interacción JS pendiente de implementación'
  end

  test "busca y selecciona profesional para slot" do
    visit project_path(@project)
  skip 'Flujo de búsqueda aún no implementado'
  end

  test "caso sin slots" do
    @project.project_slots.destroy_all
    visit project_path(@project)
  skip 'Pendiente crear proyecto sin slots en fixtures'
  end

  test "caso sin resultados en búsqueda" do
    visit project_path(@project)
  skip 'Flujo de búsqueda aún no implementado'
  end
end
