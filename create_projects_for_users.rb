#!/usr/bin/env ruby

# Script para crear proyectos para los usuarios de prueba
require_relative 'config/environment'

puts "Creando proyectos para los usuarios de prueba..."

# Buscar usuarios específicos
ana = User.find_by(email: 'ana.garcia@arqitet.com')
carlos = User.find_by(email: 'carlos.martinez@arqitet.com')
lucia = User.find_by(email: 'lucia.rodriguez@arqitet.com')
miguel = User.find_by(email: 'miguel.lopez@arqitet.com')
sofia = User.find_by(email: 'sofia.hernandez@arqitet.com')

# Datos de proyectos
projects_data = [
  {
    user: ana,
    title: 'Casa Sostenible Valle Verde',
    description: 'Diseño de vivienda unifamiliar con enfoque en sostenibilidad ambiental. Incorpora paneles solares, sistemas de recolección de agua lluvia y materiales ecológicos locales.',
    category: 'Residencial',
    location: 'Madrid, España',
    year: 2024
  },
  {
    user: carlos,
    title: 'Complejo Residencial Las Palmeras',
    description: 'Desarrollo habitacional de 50 unidades con espacios comunitarios, áreas verdes y amenidades modernas. Diseño contemporáneo que respeta el entorno natural.',
    category: 'Residencial',
    location: 'Barcelona, España',
    year: 2023
  },
  {
    user: lucia,
    title: 'Restauración Palacio del Siglo XVIII',
    description: 'Proyecto de restauración integral de palacio histórico, respetando técnicas constructivas originales mientras se incorporan sistemas modernos discretos.',
    category: 'Patrimonial',
    location: 'Sevilla, España',
    year: 2024
  },
  {
    user: miguel,
    title: 'Plaza Urbana Multifuncional',
    description: 'Diseño de espacio público que integra áreas de recreación, comercio local y zonas verdes. Fomenta la convivencia ciudadana y la movilidad sostenible.',
    category: 'Urbanismo',
    location: 'Valencia, España',
    year: 2024
  },
  {
    user: sofia,
    title: 'Oficinas Corporativas Minimalistas',
    description: 'Diseño de interiores para oficinas de empresa tecnológica. Espacios abiertos, luz natural abundante y áreas de descanso que promueven la creatividad.',
    category: 'Comercial',
    location: 'Bilbao, España',
    year: 2023
  }
]

created_projects = []

projects_data.each do |project_data|
  if project_data[:user]
    project = Project.create!(project_data)
    puts "  ✓ Proyecto creado: '#{project.title}' por #{project.user.full_name}"

    # Asignar la imagen del templo griego a cada proyecto
    image_path = Rails.root.join('public', 'templo-griego.png')
    if File.exist?(image_path)
      project.images.attach(
        io: File.open(image_path),
        filename: 'templo-griego.png',
        content_type: 'image/png'
      )
      puts "    📷 Imagen asignada"
    end

    created_projects << project
  else
    puts "  ⚠️  Usuario no encontrado para el proyecto"
  end
end

puts "\n--- Resumen ---"
puts "Proyectos creados: #{created_projects.count}"
puts "Total de proyectos en el sistema: #{Project.count}"

puts "\n--- Proyectos disponibles ---"
Project.includes(:user).order(:created_at).each do |project|
  puts "- '#{project.title}' por #{project.user.full_name} (#{project.category})"
end

puts "\n🎉 ¡Proyectos creados! Ahora puedes:"
puts "1. Ver proyectos en /projects"
puts "2. Acceder a perfiles de usuarios desde los proyectos"
puts "3. Iniciar conversaciones desde los perfiles"
