#!/usr/bin/env ruby

# Script para asignar imágenes de prueba a proyectos
# Uso: bin/rails runner lib/tasks/assign_test_images.rb

puts "🖼️  Asignando imágenes de prueba a proyectos..."

# Mapeo de proyectos a imágenes
project_images = {
  "Casa Moderna" => [ "sample_buildings/modern_tower.svg" ],
  "Edificio Central" => [ "sample_buildings/glass_office.svg" ],
  "Parque Residencial" => [ "sample_buildings/traditional_house.svg" ],
  "Torre Empresarial" => [ "sample_buildings/futuristic_city.svg" ],
  "Centro Comercial" => [ "sample_buildings/village_houses.svg" ],
  "Castillo Histórico" => [ "sample_buildings/medieval_castle.svg" ]
}

base_path = Rails.root.join("app", "assets", "images")

project_images.each do |project_title, image_files|
  # Buscar proyecto por título
  project = Project.find_by(title: project_title)

  if project.nil?
    puts "⚠️  Proyecto '#{project_title}' no encontrado, creando..."

    # Crear proyecto si no existe
    user = User.first || User.create!(
      email: "test@example.com",
      password: "password123",
      first_name: "Test",
      last_name: "User",
      confirmed_at: Time.current
    )

    project = Project.create!(
      title: project_title,
      description: "Descripción de prueba para #{project_title}. Este es un proyecto arquitectónico de ejemplo con características únicas y diseño moderno.",
      category: [ "Residencial", "Comercial", "Institucional" ].sample,
      location: [ "Madrid", "Barcelona", "Valencia", "Sevilla" ].sample,
      year: rand(2020..2025),
      user: user
    )

    puts "✅ Proyecto '#{project_title}' creado"
  else
    puts "📁 Proyecto '#{project_title}' encontrado (ID: #{project.id})"
  end

  # Limpiar imágenes existentes
  project.images.purge if project.images.attached?

  # Asignar nuevas imágenes
  image_files.each do |image_file|
    image_path = base_path.join(image_file)

    if File.exist?(image_path)
      project.images.attach(
        io: File.open(image_path),
        filename: image_file,
        content_type: "image/svg+xml"
      )
      puts "  📷 Asignada imagen: #{image_file}"
    else
      puts "  ❌ Imagen no encontrada: #{image_path}"
    end
  end

  puts "✅ Completado para '#{project_title}' (#{project.images.count} imágenes)\n"
end

puts "🎉 ¡Proceso completado! Todos los proyectos tienen imágenes de prueba."
puts "\n📊 Resumen:"
Project.includes(:images).find_each do |project|
  puts "  #{project.title}: #{project.images.count} imágenes"
end
