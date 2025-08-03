#!/usr/bin/env ruby

# Script para limpiar y recrear conversaciones de prueba
require_relative 'config/environment'

puts "Limpiando conversaciones existentes..."

# Eliminar todas las conversaciones y mensajes
Message.destroy_all
Conversation.destroy_all

puts "Conversaciones y mensajes eliminados."

# Recrear conversaciones
puts "Creando nuevas conversaciones de prueba..."

user1 = User.first
user2 = User.second

if user1 && user2
  conv = Conversation.create!(sender: user1, recipient: user2)
  puts "Conversación creada entre #{user1.full_name} y #{user2.full_name}"

  # Crear mensajes de prueba
  msg1 = conv.messages.create!(user: user1, body: "¡Hola! ¿Cómo estás?")
  msg2 = conv.messages.create!(user: user2, body: "¡Muy bien! Gracias por preguntar.")
  msg3 = conv.messages.create!(user: user1, body: "Me gusta tu proyecto de arquitectura sostenible.")

  puts "Mensajes creados:"
  puts "- #{user1.full_name}: #{msg1.body}"
  puts "- #{user2.full_name}: #{msg2.body}"
  puts "- #{user1.full_name}: #{msg3.body}"
else
  puts "No hay suficientes usuarios para crear conversaciones"
end

puts "✅ Conversaciones recreadas. Prueba el chat ahora."
