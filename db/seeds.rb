




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

puts 'Creando clientes...'
cliente = demo_user.clients.create!(
  email: 'cliente@demo.com',
  name: 'Cliente Demo',
  phone: '+34 600 000 000',
  company: 'Demo SL',
  status: 'active'
)
admin_client = admin_user.clients.create!(
  email: 'admincliente@demo.com',
  name: 'Cliente Admin',
  phone: '+34 600 000 001',
  company: 'Admin SL',
  status: 'active'
)
premium_client = premium_user.clients.create!(
  email: 'premiumcliente@demo.com',
  name: 'Cliente Premium',
  phone: '+34 600 000 002',
  company: 'Premium SL',
  status: 'active'
)


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

puts 'Creando factura con items...'
invoice = Invoice.create!(
  user: demo_user,
  project: proyecto_publico,
  client_name: cliente.name,
  client_email: cliente.email,
  client_address: 'Calle Falsa 123, Madrid',
  issue_date: Date.current - 2.days,
  due_date: Date.current + 28.days,
  status: 0,
  tax_rate: 21.0,
  notes: 'Factura de ejemplo.'
)
invoice.invoice_items.create!([
  { description: 'Proyecto básico', quantity: 1, unit_price: 600.00, total: 0 },
  { description: 'Dirección de obra', quantity: 1, unit_price: 400.00, total: 0 }
])
invoice.save!

puts 'Creando documento adjunto...'
doc = proyecto_publico.documents.build(
  name: 'Memoria Descriptiva',
  description: 'Documento principal del proyecto.',
  category: 'specification',
  user: demo_user,
  uploaded_by: demo_user
)
temp_file = Tempfile.new([ 'memoria', '.txt' ])
temp_file.write("Memoria Descriptiva\n\nProyecto: #{proyecto_publico.title}")
temp_file.rewind
doc.file.attach(io: temp_file, filename: 'memoria.txt', content_type: 'text/plain')
doc.save!
temp_file.close
temp_file.unlink

puts 'Creando tarea y hito...'
proyecto_publico.project_tasks.create!(
  name: 'Levantamiento topográfico',
  description: 'Medición del terreno',
  start_date: Date.current,
  end_date: Date.current + 1.week,
  priority: 4,
  status: 'completed',
  progress: 100,
  assigned_to: demo_user,
  position: 1
)
proyecto_publico.project_milestones.create!(
  name: 'Aprobación del cliente',
  description: 'El cliente aprueba el diseño',
  target_date: Date.current + 1.month,
  status: 'pending',
  position: 1
)
puts 'Seed completo.'
