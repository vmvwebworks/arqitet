require "application_system_test_case"

class HomeViewTest < ApplicationSystemTestCase
  setup do
    sign_in_user
  end

  test "muestra el dashboard/home" do
    visit root_path
    assert_selector "h1", text: /Hola|Resumen/
  end
end
