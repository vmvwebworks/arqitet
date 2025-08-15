# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Crear usuario de ejemplo si no existe
demo_user = User.find_or_create_by!(email: 'arquitecto@demo.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.full_name = 'Ana García Arquitecta'
  user.slug = 'ana-garcia-arquitecta'
  user.bio = 'Arquitecta especializada en vivienda sostenible y rehabilitación de edificios históricos.'
  user.confirmed_at = Time.current
end

# Crear proyectos públicos de ejemplo
puts "Creando proyectos de ejemplo..."

public_projects_data = [
  {
    title: 'Casa Sostenible en la Sierra',
    description: 'Vivienda unifamiliar diseñada con criterios de sostenibilidad y eficiencia energética, integrada en el paisaje natural.',
    category: 'residential',
    location: 'Sierra de Madrid',
    year: 2023,
    is_public: true
  },
  {
    title: 'Rehabilitación Centro Histórico',
    description: 'Proyecto de rehabilitación integral de edificio del siglo XVIII para uso residencial y comercial.',
    category: 'restoration',
    location: 'Toledo',
    year: 2024,
    is_public: true
  },
  {
    title: 'Oficinas Corporativas Eco',
    description: 'Diseño de oficinas corporativas con certificación LEED y espacios colaborativos innovadores.',
    category: 'commercial',
    location: 'Barcelona',
    year: 2024,
    is_public: true
  }
]

public_projects_data.each do |project_data|
  Project.find_or_create_by!(
    title: project_data[:title],
    user: demo_user
  ) do |project|
    project.assign_attributes(project_data)
  end
end

# Crear proyectos de gestión de ejemplo
management_projects_data = [
  {
    title: 'Vivienda Unifamiliar Delgado',
    description: 'Proyecto de vivienda unifamiliar de nueva construcción para la familia Delgado.',
    category: 'residential',
    location: 'Las Rozas, Madrid',
    year: 2024,
    is_public: false,
    client_name: 'Carmen Delgado',
    client_email: 'carmen.delgado@email.com',
    client_phone: '+34 666 123 456',
    budget: 350000.00,
    surface_area: 280.50,
    status: 'in_progress',
    project_type: 'new_construction',
    start_date: Date.current - 2.months,
    expected_end_date: Date.current + 8.months
  },
  {
    title: 'Reforma Local Comercial Centro',
    description: 'Reforma integral de local comercial para nueva boutique de moda.',
    category: 'commercial',
    location: 'Centro, Madrid',
    year: 2024,
    is_public: false,
    client_name: 'Innovación Retail SL',
    client_email: 'info@innovacionretail.com',
    client_phone: '+34 91 234 5678',
    budget: 85000.00,
    surface_area: 120.00,
    status: 'in_progress',
    project_type: 'renovation',
    start_date: Date.current - 1.month,
    expected_end_date: Date.current + 3.months
  },
  {
    title: 'Ampliación Casa Rural',
    description: 'Proyecto de ampliación de casa rural existente con nueva ala para huéspedes.',
    category: 'residential',
    location: 'Segovia',
    year: 2024,
    is_public: false,
    client_name: 'José María Ruiz',
    client_email: 'jm.ruiz@casarural.es',
    client_phone: '+34 666 789 012',
    budget: 120000.00,
    surface_area: 150.00,
    status: 'proposal',
    project_type: 'extension',
    start_date: Date.current - 3.months,
    expected_end_date: Date.current + 6.months
  }
]

management_projects_data.each do |project_data|
  Project.find_or_create_by!(
    title: project_data[:title],
    user: demo_user
  ) do |project|
    project.assign_attributes(project_data)
  end
end

puts "✓ Proyectos de ejemplo creados: #{Project.count} total"

# Crear planes de suscripción
puts "Creando planes de suscripción..."

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
    'Gestión de clientes',
    'Calculadora de honorarios',
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
    'Gestión de clientes',
    'Calculadora de honorarios',
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
