require "application_system_test_case"

class UsersViewTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    sign_in_user(@user)
  end

  test "muestra la vista de usuarios" do
  visit search_users_path
  assert_selector "h1", text: /Buscar profesionales/
  # La búsqueda puede estar vacía; sólo validamos que la página carga autenticada.
  assert_selector "form"
  end
end
