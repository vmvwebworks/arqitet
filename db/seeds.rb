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

# Crear tarifas de honorarios para diferentes regiones y tipos de proyecto
puts "Creando tarifas de honorarios..."

# Tarifas generales por tipo de proyecto (base para toda España)
general_rates = {
  'Vivienda unifamiliar' => 8.50,
  'Vivienda plurifamiliar' => 7.80,
  'Local comercial' => 6.20,
  'Oficinas' => 6.50,
  'Industrial' => 5.80,
  'Rehabilitación' => 9.20,
  'Reforma' => 10.50,
  'Ampliación' => 8.80,
  'Proyecto básico' => 6.00,
  'Proyecto de ejecución' => 12.50
}

general_rates.each do |project_type, rate|
  RateTariff.find_or_create_by!(
    region: 'General',
    project_type: project_type
  ) do |tariff|
    tariff.base_rate = rate
    tariff.min_rate = rate * 0.8
    tariff.max_rate = rate * 1.2
    tariff.active = true
  end
end

# Tarifas específicas por comunidades autónomas (con variaciones)
regional_multipliers = {
  'Madrid' => 1.15,
  'Cataluña' => 1.12,
  'País Vasco' => 1.18,
  'Andalucía' => 0.95,
  'Valencia' => 1.05,
  'Galicia' => 0.92,
  'Castilla y León' => 0.88,
  'Aragón' => 0.90,
  'Asturias' => 0.93,
  'Cantabria' => 0.94,
  'Murcia' => 0.91,
  'Baleares' => 1.20,
  'Canarias' => 1.10,
  'Extremadura' => 0.85,
  'Castilla-La Mancha' => 0.87,
  'La Rioja' => 0.89,
  'Navarra' => 1.08
}

regional_multipliers.each do |region, multiplier|
  general_rates.each do |project_type, base_rate|
    adjusted_rate = base_rate * multiplier
    
    RateTariff.find_or_create_by!(
      region: region,
      project_type: project_type
    ) do |tariff|
      tariff.base_rate = adjusted_rate
      tariff.min_rate = adjusted_rate * 0.8
      tariff.max_rate = adjusted_rate * 1.2
      tariff.active = true
    end
  end
end

puts "✓ Tarifas de honorarios creadas para #{RateTariff.count} combinaciones región/proyecto"

# AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
