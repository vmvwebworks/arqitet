module ClientsHelper
  def client_status_options
    [
      ['Contacto', 'lead'],
      ['Prospecto', 'prospect'], 
      ['Cliente Activo', 'active'],
      ['Inactivo', 'inactive'],
      ['Cerrado', 'closed']
    ]
  end

  def interaction_type_options
    [
      ['Llamada', 'call'], 
      ['Email', 'email'], 
      ['Reunión', 'meeting'], 
      ['Nota', 'note'], 
      ['Propuesta', 'proposal'], 
      ['Contrato', 'contract']
    ]
  end

  def client_value_formatted(client)
    value = client.total_project_value
    return "€0.00" if value.zero?
    "€#{sprintf('%.2f', value)}"
  end

  def last_interaction_text(client)
    return "Sin interacciones" unless client.last_interaction
    
    interaction = client.last_interaction
    "#{interaction.interaction_type_spanish} - #{time_ago_in_words(interaction.date)} ago"
  end
end
