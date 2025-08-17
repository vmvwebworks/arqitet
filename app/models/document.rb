class Document < ApplicationRecord
  belongs_to :project
  belongs_to :user
  belongs_to :uploaded_by, class_name: 'User', optional: true
  has_one_attached :file

  validates :name, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 1000 }
  validates :category, presence: true
  validates :file, presence: true
  validates :version, presence: true, numericality: { greater_than: 0 }
  
  validate :acceptable_file

  private

  def acceptable_file
    return unless file.attached?

    # Validar tamaño del archivo (máximo 10MB)
    if file.blob.byte_size > 10.megabytes
      errors.add(:file, 'debe ser menor a 10MB')
    end

    # Validar tipos de archivo permitidos
    acceptable_types = %w[
      application/pdf
      application/msword
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
      application/vnd.ms-excel
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      application/vnd.ms-powerpoint
      application/vnd.openxmlformats-officedocument.presentationml.presentation
      text/plain
      image/jpeg
      image/png
      image/gif
      image/svg+xml
      application/zip
      application/x-rar-compressed
    ]

    unless acceptable_types.include?(file.blob.content_type)
      errors.add(:file, 'debe ser un archivo PDF, DOC, XLS, PPT, TXT, imagen, o archivo comprimido')
    end
  end

  enum category: {
    contract: 'contract',
    plan: 'plan',
    permit: 'permit',
    specification: 'specification',
    invoice: 'invoice',
    photo: 'photo',
    report: 'report',
    other: 'other'
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(category) { where(category: category) }
  scope :latest_versions, -> { 
    select('documents.*, ROW_NUMBER() OVER (PARTITION BY name ORDER BY version DESC) as rn')
    .having('rn = 1')
  }

  before_validation :set_file_info, if: -> { file.attached? }
  before_validation :set_initial_version, on: :create

  def file_extension
    return '' unless file.attached?
    File.extname(file.filename.to_s).downcase
  end

  def file_icon
    case file_extension
    when '.pdf' then 'file-text'
    when '.doc', '.docx' then 'file-text'
    when '.xls', '.xlsx' then 'grid'
    when '.dwg', '.dxf' then 'layers'
    when '.jpg', '.jpeg', '.png', '.gif' then 'image'
    when '.zip', '.rar' then 'archive'
    else 'file'
    end
  end

  def category_spanish
    case category
    when 'contract' then 'Contrato'
    when 'plan' then 'Plano'
    when 'permit' then 'Permiso'
    when 'specification' then 'Memoria'
    when 'invoice' then 'Factura'
    when 'photo' then 'Fotografía'
    when 'report' then 'Informe'
    when 'other' then 'Otro'
    end
  end

  def category_badge_class
    case category
    when 'contract' then 'bg-red-100 text-red-800'
    when 'plan' then 'bg-blue-100 text-blue-800'
    when 'permit' then 'bg-green-100 text-green-800'
    when 'specification' then 'bg-purple-100 text-purple-800'
    when 'invoice' then 'bg-yellow-100 text-yellow-800'
    when 'photo' then 'bg-pink-100 text-pink-800'
    when 'report' then 'bg-indigo-100 text-indigo-800'
    when 'other' then 'bg-gray-100 text-gray-800'
    end
  end

  def file_size_human
    return '0 B' unless file_size

    units = ['B', 'KB', 'MB', 'GB']
    size = file_size.to_f
    unit_index = 0

    while size >= 1024 && unit_index < units.length - 1
      size /= 1024
      unit_index += 1
    end

    "#{size.round(1)} #{units[unit_index]}"
  end

  def is_image?
    %w[.jpg .jpeg .png .gif .webp].include?(file_extension)
  end

  def downloadable_url
    Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
  end

  private

  def set_file_info
    return unless file.attached?
    
    self.file_size = file.byte_size
    self.file_type = file.content_type
    self.name = file.filename.to_s if name.blank?
  end

  def set_initial_version
    self.version = 1 if version.blank?
  end

  def acceptable_file
    return unless file.attached?

    # Validar tamaño del archivo (máximo 10MB)
    if file.blob.byte_size > 10.megabytes
      errors.add(:file, 'debe ser menor a 10MB')
    end

    # Validar tipos de archivo permitidos
    acceptable_types = %w[
      application/pdf
      application/msword
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
      application/vnd.ms-excel
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      application/vnd.ms-powerpoint
      application/vnd.openxmlformats-officedocument.presentationml.presentation
      text/plain
      image/jpeg
      image/png
      image/gif
      image/svg+xml
      application/zip
      application/x-rar-compressed
    ]

    unless acceptable_types.include?(file.blob.content_type)
      errors.add(:file, 'debe ser un archivo PDF, DOC, XLS, PPT, TXT, imagen, o archivo comprimido')
    end
  end
end
