# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Crear planes de suscripción
SubscriptionPlan.find_or_create_by!(name: 'Gratuito') do |plan|
  plan.description = 'Plan básico gratuito con funciones limitadas'
  plan.price_cents = 0
  plan.interval = 'month'
  plan.features = [ 'Ver proyectos públicos', 'Crear hasta 3 proyectos', 'Chat básico' ]
  plan.active = true
end

SubscriptionPlan.find_or_create_by!(name: 'Pro') do |plan|
  plan.description = 'Plan profesional con todas las funciones'
  plan.price_cents = 999  # 9.99 EUR
  plan.interval = 'month'
  plan.features = [
    'Proyectos ilimitados',
    'Chat avanzado',
    'Favoritos ilimitados',
    'Acceso prioritario',
    'Soporte técnico'
  ]
  plan.active = true
end

SubscriptionPlan.find_or_create_by!(name: 'Pro Anual') do |plan|
  plan.description = 'Plan profesional anual con descuento'
  plan.price_cents = 9999  # 99.99 EUR (2 meses gratis)
  plan.interval = 'year'
  plan.features = [
    'Proyectos ilimitados',
    'Chat avanzado',
    'Favoritos ilimitados',
    'Acceso prioritario',
    'Soporte técnico premium',
    '2 meses gratis'
  ]
  plan.active = true
end

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
