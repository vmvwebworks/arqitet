# Sistema de Gestión Documental

## Descripción

El sistema de gestión documental permite a los arquitectos organizar y gestionar todos los documentos relacionados con sus proyectos de manera centralizada y eficiente.

## Características Principales

### 📁 Organización por Categorías
- **Contratos**: Documentos contractuales del proyecto
- **Planos**: Planos arquitectónicos y técnicos
- **Permisos**: Licencias y permisos oficiales
- **Memorias**: Memorias descriptivas y técnicas
- **Facturas**: Documentos de facturación
- **Fotografías**: Imágenes del proyecto
- **Informes**: Reportes y estudios
- **Otros**: Documentos diversos

### 🔒 Control de Acceso
- Solo el propietario del proyecto puede ver y gestionar sus documentos
- Validación de permisos en todos los endpoints
- Integración con el sistema de autenticación Devise

### 📤 Subida de Archivos
- **Drag & Drop**: Interfaz intuitiva para subir archivos
- **Tipos soportados**: PDF, DOC, XLS, PPT, TXT, imágenes, archivos comprimidos
- **Límite de tamaño**: Máximo 10MB por archivo
- **Auto-completado**: El nombre se genera automáticamente del archivo si no se especifica

### 📊 Dashboard Visual
- Estadísticas del proyecto (total documentos, categorías, espacio usado)
- Filtros por categoría
- Vista de tabla con información detallada
- Iconos según tipo de archivo

### 🔧 Gestión Completa
- **Subir**: Formulario completo con validaciones
- **Visualizar**: Lista organizada y paginada
- **Descargar**: Descarga directa de archivos
- **Eliminar**: Eliminación con confirmación

## Estructura Técnica

### Modelo Document
```ruby
belongs_to :project
belongs_to :user
belongs_to :uploaded_by, class_name: 'User', optional: true
has_one_attached :file

# Enums para categorías
# Validaciones de archivo y tamaño
# Métodos helper para presentación
```

### Controlador DocumentsController
- Autenticación requerida
- Validación de acceso al proyecto
- CRUD completo con manejo de errores

### Rutas Anidadas
```ruby
resources :projects do
  resources :documents, except: [:edit, :update] do
    member do
      get :download
    end
  end
end
```

## Uso

### Acceso al Sistema
1. Desde la vista del proyecto: botón "Documentos"
2. Desde la lista de proyectos: botón "Documentos" (solo tus proyectos)

### Subir Documentos
1. Clic en "Subir Documento"
2. Arrastrar archivo o hacer clic para seleccionar
3. Completar información (nombre, descripción, categoría)
4. Confirmar subida

### Gestionar Documentos
- **Filtrar**: Usar las pestañas de categoría
- **Descargar**: Clic en el ícono de descarga
- **Eliminar**: Clic en el ícono de basura (con confirmación)

## Integración con ActiveStorage

El sistema utiliza ActiveStorage de Rails para:
- Almacenamiento seguro de archivos
- Generación automática de URLs de descarga
- Metadatos de archivos (tamaño, tipo, nombre)
- Validaciones de contenido

## Datos de Ejemplo

El seed incluye documentos de ejemplo para los proyectos públicos:
- Memorias descriptivas
- Planos de planta  
- Presupuestos generales

## Próximas Mejoras

- [ ] Versionado de documentos
- [ ] Previsualización de archivos
- [ ] Búsqueda dentro de documentos
- [ ] Compartir documentos con clientes
- [ ] Firma digital de documentos
- [ ] Sincronización con sistemas externos
