require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
  include Warden::Test::Helpers if defined?(Warden::Test::Helpers)
  include Devise::Test::IntegrationHelpers if defined?(Devise)

  def after_teardown
    Warden.test_reset! if defined?(Warden)
    super
  end

  # Helper método para login manteniendo pruebas simplificadas
  def sign_in_user(user = users(:one))
    user.confirm if !user.confirmed?
    user.save!
    login_as user, scope: :user
  end
end
