#!/usr/bin/env ruby

# Script para crear usuarios de prueba para el sistema de chat
require_relative 'config/environment'

puts "Creando usuarios de prueba para el sistema de chat..."

# Datos de usuarios de prueba
users_data = [
  {
    email: 'ana.garcia@arqitet.com',
    full_name: 'Ana García',
    password: 'password123',
    bio: 'Arquitecta especializada en diseño sostenible y construcción ecológica.'
  },
  {
    email: 'carlos.martinez@arqitet.com',
    full_name: 'Carlos Martínez',
    password: 'password123',
    bio: 'Arquitecto con 15 años de experiencia en proyectos residenciales y comerciales.'
  },
  {
    email: 'lucia.rodriguez@arqitet.com',
    full_name: 'Lucía Rodríguez',
    password: 'password123',
    bio: 'Especialista en restauración de edificios históricos y patrimonio arquitectónico.'
  },
  {
    email: 'miguel.lopez@arqitet.com',
    full_name: 'Miguel López',
    password: 'password123',
    bio: 'Arquitecto urbanista enfocado en planificación de espacios públicos.'
  },
  {
    email: 'sofia.hernandez@arqitet.com',
    full_name: 'Sofía Hernández',
    password: 'password123',
    bio: 'Arquitecta de interiores con pasión por el diseño minimalista.'
  }
]

created_users = []

users_data.each do |user_data|
  # Verificar si el usuario ya existe
  existing_user = User.find_by(email: user_data[:email])

  if existing_user
    puts "  ⚠️  Usuario #{user_data[:email]} ya existe, saltando..."
    created_users << existing_user
  else
    user = User.create!(user_data)
    puts "  ✓ Usuario creado: #{user.full_name} (#{user.email})"
    created_users << user
  end
end

puts "\n--- Resumen ---"
puts "Total de usuarios creados/verificados: #{created_users.count}"
puts "Total de usuarios en el sistema: #{User.count}"

puts "\n--- Usuarios disponibles para chat ---"
User.all.each do |user|
  puts "- #{user.full_name} (#{user.email})"
end

puts "\n--- Crear algunas conversaciones de prueba ---"

# Crear conversaciones entre usuarios si hay al least 2 usuarios
if User.count >= 2
  users = User.all.to_a

  # Crear conversación entre los primeros dos usuarios
  user1 = users[0]
  user2 = users[1]

  conv1 = Conversation.between(user1.id, user2.id).first_or_create(sender: user1, recipient: user2)
  puts "Conversación creada entre #{user1.full_name} y #{user2.full_name}"

  # Crear algunos mensajes de prueba
  messages = [
    { user: user1, body: "¡Hola! Vi tu proyecto de la casa sostenible, muy interesante." },
    { user: user2, body: "¡Gracias! Me encanta trabajar con materiales ecológicos." },
    { user: user1, body: "¿Podrías contarme más sobre los paneles solares que usaste?" },
    { user: user2, body: "Por supuesto, usamos paneles de última generación con un 22% de eficiencia." }
  ]

  messages.each do |msg_data|
    message = conv1.messages.create!(
      user: msg_data[:user],
      body: msg_data[:body]
    )
    puts "  💬 Mensaje: #{msg_data[:user].full_name.split.first}: #{msg_data[:body][0..30]}..."
  end

  # Crear otra conversación si hay más usuarios
  if users.count >= 3
    user3 = users[2]
    conv2 = Conversation.between(user1.id, user3.id).first_or_create(sender: user1, recipient: user3)
    puts "Conversación creada entre #{user1.full_name} y #{user3.full_name}"

    conv2.messages.create!(
      user: user1,
      body: "Hola, me gustaría saber más sobre restauración de edificios históricos."
    )
    conv2.messages.create!(
      user: user3,
      body: "¡Hola! Es mi especialidad, ¿tienes algún proyecto en mente?"
    )
  end
end

puts "\n🎉 ¡Script completado! Ya puedes probar el sistema de chat."
puts "Para probar:"
puts "1. Inicia sesión con cualquiera de estos usuarios"
puts "2. Ve a /conversations para ver las conversaciones"
puts "3. Prueba enviar mensajes en tiempo real"
