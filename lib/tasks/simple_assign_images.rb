#!/usr/bin/env ruby

# Script simple para asignar imágenes de prueba
puts "🖼️  Asignando imágenes de edificios a proyectos existentes..."

# Obtener proyectos existentes
projects = Project.limit(6)

if projects.empty?
  puts "❌ No hay proyectos para actualizar"
  exit
end

# Imágenes de edificios disponibles
building_images = [
  "sample_buildings/modern_tower.svg",
  "sample_buildings/traditional_house.svg",
  "sample_buildings/glass_office.svg",
  "sample_buildings/village_houses.svg",
  "sample_buildings/medieval_castle.svg",
  "sample_buildings/futuristic_city.svg"
]

base_path = Rails.root.join("app", "assets", "images")

projects.each_with_index do |project, index|
  # Seleccionar imagen según el índice
  building_image = building_images[index % building_images.length]
  image_path = base_path.join(building_image)

  if File.exist?(image_path)
    # Solo agregar si no tiene imágenes
    unless project.images.attached?
      project.images.attach(
        io: File.open(image_path),
        filename: File.basename(building_image),
        content_type: "image/svg+xml"
      )
      puts "✅ #{project.title}: Asignada imagen #{building_image}"
    else
      puts "⚠️  #{project.title}: Ya tiene imágenes (#{project.images.count})"
    end
  else
    puts "❌ Imagen no encontrada: #{image_path}"
  end
end

puts "\n🎉 ¡Proceso completado!"
