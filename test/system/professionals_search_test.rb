require "application_system_test_case"

class ProfessionalsSearchTest < ApplicationSystemTestCase
  setup do
    sign_in_user
  end

  test "muestra la vista de búsqueda de profesionales" do
    visit search_users_path
    assert_selector "h1", text: "Buscar profesionales"
    assert_selector "form"
  end
end
