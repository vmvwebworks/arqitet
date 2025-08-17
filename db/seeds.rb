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

# Crear clientes de ejemplo para el CRM
puts "Creando clientes de ejemplo para el CRM..."

clients_data = [
  {
    name: 'María García López',
    email: 'maria.garcia@constructora.com',
    phone: '+34 666 111 222',
    company: 'Constructora García S.L.',
    tax_id: 'B12345678',
    website: 'https://www.constructora-garcia.com',
    address: 'Av. de la Constitución 45, 3ºA, 41001 Sevilla',
    status: 'active',
    notes: 'Cliente muy exigente con la calidad. Prefiere materiales ecológicos.'
  },
  {
    name: 'Carlos Ruiz Martínez',
    email: 'carlos@ruizpromotor.es',
    phone: '+34 666 333 444',
    company: 'Promociones Ruiz',
    tax_id: 'B87654321',
    website: 'https://www.promociones-ruiz.es',
    address: 'Calle Gran Vía 123, 28013 Madrid',
    status: 'prospect',
    notes: 'Interesado en proyectos de vivienda plurifamiliar. Volumen alto.'
  },
  {
    name: 'Ana Fernández Silva',
    email: 'ana.fernandez@gmail.com',
    phone: '+34 666 555 666',
    company: nil,
    tax_id: '12345678Z',
    website: nil,
    address: 'Carrer de Balmes 89, 08008 Barcelona',
    status: 'lead',
    notes: 'Primera vivienda. Presupuesto ajustado pero muy motivada.'
  },
  {
    name: 'José Manuel Torres',
    email: 'jm.torres@empresarial.com',
    phone: '+34 666 777 888',
    company: 'Grupo Empresarial Torres',
    tax_id: 'A98765432',
    website: 'https://www.grupo-torres.com',
    address: 'Polígono Industrial Norte, Nave 15, 46980 Paterna, Valencia',
    status: 'active',
    notes: 'Cliente corporativo. Proyectos industriales y oficinas.'
  }
]

clients_data.each do |client_data|
  client = demo_user.clients.find_or_create_by!(
    email: client_data[:email]
  ) do |c|
    c.assign_attributes(client_data)
    c.created_by = demo_user
  end
  
  # Crear algunas interacciones de ejemplo
  if client.interactions.empty?
    interactions_data = [
      {
        interaction_type: 'call',
        subject: 'Llamada inicial de contacto',
        content: 'Primera conversación para entender las necesidades del cliente.',
        date: 2.weeks.ago
      },
      {
        interaction_type: 'email',
        subject: 'Envío de propuesta inicial',
        content: 'Enviada propuesta económica y cronograma preliminar.',
        date: 1.week.ago
      }
    ]
    
    interactions_data.each do |interaction_data|
      client.interactions.create!(
        interaction_data.merge(user: demo_user)
      )
    end
  end
end

puts "✓ Clientes de ejemplo creados: #{Client.count} total"
puts "✓ Interacciones de ejemplo creadas: #{Interaction.count} total"

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

# Crear documentos de ejemplo para los proyectos
puts "Creando documentos de ejemplo..."

Project.where(is_public: true).limit(2).each do |project|
  # Crear algunos documentos de ejemplo para cada proyecto
  documents_data = [
    {
      name: "Memoria Descriptiva - #{project.title}",
      description: "Documento principal con la descripción detallada del proyecto arquitectónico.",
      category: 'specification'
    },
    {
      name: "Planos de Planta - #{project.title}",
      description: "Planos arquitectónicos de plantas del proyecto.",
      category: 'plan'
    },
    {
      name: "Presupuesto General - #{project.title}",
      description: "Presupuesto detallado de la obra y honorarios profesionales.",
      category: 'invoice'
    }
  ]

  documents_data.each do |doc_data|
    unless project.documents.exists?(name: doc_data[:name])
      document = project.documents.build(doc_data)
      document.user = project.user
      document.uploaded_by = project.user
      
      # Crear un archivo de texto de ejemplo
      temp_file = Tempfile.new(['document', '.txt'])
      temp_file.write("Contenido de ejemplo para #{doc_data[:name]}\n\nEste es un documento de demostración creado automáticamente para mostrar la funcionalidad del sistema de gestión documental.\n\nFecha de creación: #{Time.current}\nProyecto: #{project.title}\nCategoría: #{doc_data[:category]}")
      temp_file.rewind
      
      document.file.attach(
        io: temp_file,
        filename: "#{doc_data[:name].parameterize}.txt",
        content_type: 'text/plain'
      )
      
      if document.save
        puts "  ✓ Documento creado: #{document.name}"
      else
        puts "  ✗ Error creando documento: #{document.errors.full_messages.join(', ')}"
      end
      
      temp_file.close
      temp_file.unlink
    end
  end
end

puts "✓ Documentos de ejemplo creados"
