# SEED ROBUSTO Y FUNCIONAL
puts 'Eliminando datos previos...'
InvoiceItem.delete_all if defined?(InvoiceItem)
Invoice.delete_all if defined?(Invoice)
Document.delete_all if defined?(Document)
ProjectTask.delete_all if defined?(ProjectTask)
ProjectMilestone.delete_all if defined?(ProjectMilestone)
Client.delete_all
Project.delete_all
User.delete_all

puts 'Creando usuarios...'
demo_user = User.create!(
  email: 'arquitecto@demo.com',
  password: 'password123',
  full_name: 'Ana García Arquitecta',
  confirmed_at: Time.current,
  role: 'user'
)
admin_user = User.create!(
  email: 'admin@demo.com',
  password: 'admin1234',
  full_name: 'Admin Demo',
  confirmed_at: Time.current,
  role: 'admin'
)
premium_user = User.create!(
  email: 'premium@demo.com',
  password: 'premium1234',
  full_name: 'Usuario Premium',
  confirmed_at: Time.current,
  role: 'user'
)

# USUARIOS ADICIONALES
10.times do |i|
  User.create!(
    email: "user#{i+1}@demo.com",
    password: 'password123',
    full_name: "Usuario #{i+1}",
    confirmed_at: Time.current,
    role: i.even? ? 'user' : 'admin'
  )
end

puts 'Creando clientes...'
cliente = demo_user.clients.create!(
  email: 'cliente@demo.com',
  name: 'Cliente Demo',
  phone: '+34 600 000 000',
  company: 'Demo SL',
  status: 'active',
  created_by_id: demo_user.id
)
admin_client = admin_user.clients.create!(
  email: 'admincliente@demo.com',
  name: 'Cliente Admin',
  phone: '+34 600 000 001',
  company: 'Admin SL',
  status: 'active',
  created_by_id: admin_user.id
)
premium_client = premium_user.clients.create!(
  email: 'premiumcliente@demo.com',
  name: 'Cliente Premium',
  phone: '+34 600 000 002',
  company: 'Premium SL',
  status: 'active',
  created_by_id: premium_user.id
)

# CLIENTES ADICIONALES
User.all.each do |user|
  3.times do |i|
    Client.create!(
      email: "cliente#{i+1}_#{user.id}@demo.com",
      name: "Cliente #{i+1} de #{user.full_name}",
      phone: "+34 600 000 10#{i+1}",
      company: "Empresa #{i+1}",
      status: Client.statuses.keys.sample,
      created_by_id: user.id,
      user: user
    )
  end
end

puts 'Creando proyectos...'
proyecto_publico = Project.create!(
  title: 'Casa Sostenible',
  user: demo_user,
  description: 'Vivienda eficiente y ecológica.',
  category: 'residential',
  location: 'Madrid',
  year: 2025,
  is_public: true,
  budget: 150000.0,
  surface_area: 120.0
)
# Adjuntar archivo IFC demo
if File.exist?(Rails.root.join('db/demo.ifc'))
  proyecto_publico.cad_file.attach(
    io: File.open(Rails.root.join('db/demo.ifc')),
    filename: 'demo.ifc',
    content_type: 'application/octet-stream'
  )
end
proyecto_publico2 = Project.create!(
  title: 'Edificio Solar',
  user: demo_user,
  description: 'Edificio de oficinas sostenible.',
  category: 'commercial',
  location: 'Madrid',
  year: 2025,
  is_public: true,
  budget: 500000.0,
  surface_area: 800.0
)
# Adjuntar archivo SVG demo
if File.exist?(Rails.root.join('db/demo.svg'))
  proyecto_publico2.cad_file.attach(
    io: File.open(Rails.root.join('db/demo.svg')),
    filename: 'demo.svg',
    content_type: 'image/svg+xml'
  )
end
admin_project = Project.create!(
  title: 'Proyecto Admin',
  user: admin_user,
  description: 'Proyecto exclusivo para administración.',
  category: 'institutional',
  location: 'Barcelona',
  year: 2025,
  is_public: true,
  budget: 1000000.0,
  surface_area: 2000.0
)
premium_project = Project.create!(
  title: 'Proyecto Premium',
  user: premium_user,
  description: 'Proyecto para usuario premium.',
  category: 'residential',
  location: 'Valencia',
  year: 2025,
  is_public: true,
  budget: 300000.0,
  surface_area: 300.0
)

# PROYECTOS ADICIONALES
Client.all.each do |client|
  2.times do |i|
    p = Project.create!(
      title: "Proyecto #{i+1} de #{client.name}",
      user: client.user,
      description: "Descripción del proyecto #{i+1} de #{client.name}",
      category: %w[residential commercial institutional industrial].sample,
      location: %w[Madrid Barcelona Valencia Sevilla Bilbao].sample,
      year: 2023 + i,
      is_public: [true, false].sample,
      budget: rand(100_000..1_000_000),
      surface_area: rand(80..2000),
      client_name: client.name,
      client_email: client.email,
      client_phone: client.phone,
      status: Project.statuses.keys.sample,
      visits: rand(0..1000)
    )
    # FACTURAS
    inv = Invoice.create!(
      user: client.user,
      project: p,
      client_name: client.name,
      client_email: client.email,
      client_address: "Calle #{rand(1..100)}, Ciudad",
      issue_date: Date.current - rand(1..30).days,
      due_date: Date.current + rand(10..40).days,
      status: 0,
      tax_rate: 21.0,
      notes: 'Factura generada automáticamente.',
      invoice_number: "INV-#{client.id}-#{p.id}-#{i}-#{rand(1000..9999)}"
    )
    inv.invoice_items.create!([
      { description: 'Servicio principal', quantity: 1, unit_price: rand(500..2000), total: 0 },
      { description: 'Extra', quantity: 2, unit_price: rand(100..500), total: 0 }
    ])
    # DOCUMENTOS
    doc = p.documents.build(
      name: "Documento #{i+1}",
      description: "Documento generado para #{p.title}",
      category: 'specification',
      user: client.user,
      uploaded_by: client.user
    )
    temp_file = Tempfile.new([ "doc_#{i+1}", '.txt' ])
    temp_file.write("Documento de prueba para #{p.title}")
    temp_file.rewind
    doc.file.attach(io: temp_file, filename: "doc_#{i+1}.txt", content_type: 'text/plain')
    doc.save!
    temp_file.close
    temp_file.unlink
    # TAREAS Y HITOS
    2.times do |j|
      p.project_tasks.create!(
        name: "Tarea #{j+1} de #{p.title}",
        description: "Descripción de la tarea #{j+1}",
        start_date: Date.current - rand(1..10).days,
        end_date: Date.current + rand(1..20).days,
        priority: rand(1..5),
        status: ProjectTask.statuses.keys.sample,
        progress: rand(0..100),
        assigned_to: client.user,
        position: j+1
      )
      p.project_milestones.create!(
        name: "Hito #{j+1} de #{p.title}",
        description: "Descripción del hito #{j+1}",
        target_date: Date.current + rand(10..60).days,
        status: ProjectMilestone.statuses.keys.sample,
        position: j+1
      )
    end
  end
end

# ASIGNAR IMÁGENES A LOS PROYECTOS
image_paths = Dir[Rails.root.join('app/assets/images/demo*')].select { |f| f =~ /\.(jpg|jpeg|png|gif)$/i }
if image_paths.any?
  Project.all.each_with_index do |project, idx|
    img_path = image_paths[idx % image_paths.size]
    project.images.attach(
      io: File.open(img_path),
      filename: File.basename(img_path),
      content_type: 'image/png'
    )
  end
  puts "Imágenes de ejemplo asignadas a los proyectos."
else
  puts "No se encontraron imágenes de ejemplo en app/assets/images/ (archivos demo*.jpg/png/gif)."
end

puts 'Seed completo.'
