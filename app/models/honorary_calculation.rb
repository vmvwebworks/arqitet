class HonoraryCalculation < ApplicationRecord
  belongs_to :user

  validates :project_type, presence: true
  validates :surface_area, presence: true, numericality: { greater_than: 0 }
  validates :location, presence: true
  validates :complexity_factor, presence: true, numericality: { greater_than: 0 }
  validates :base_rate, presence: true, numericality: { greater_than: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  serialize :calculation_data, coder: JSON

  PROJECT_TYPES = [
    'Vivienda unifamiliar',
    'Vivienda plurifamiliar',
    'Local comercial',
    'Oficinas',
    'Industrial',
    'Rehabilitación',
    'Reforma',
    'Ampliación',
    'Proyecto básico',
    'Proyecto de ejecución'
  ].freeze

  COMPLEXITY_FACTORS = {
    'Muy básico' => 0.8,
    'Básico' => 1.0,
    'Estándar' => 1.2,
    'Complejo' => 1.5,
    'Muy complejo' => 2.0
  }.freeze

  def self.calculate_honorary(params)
    surface_area = params[:surface_area].to_f
    project_type = params[:project_type]
    location = params[:location]
    complexity = params[:complexity]

    # Buscar tarifa base
    tariff = RateTariff.find_by(
      region: location, 
      project_type: project_type, 
      active: true
    ) || RateTariff.find_by(
      region: 'General', 
      project_type: project_type, 
      active: true
    )

    return nil unless tariff

    base_rate = tariff.base_rate.to_f
    complexity_factor = COMPLEXITY_FACTORS[complexity] || 1.0
    
    # Cálculo por tramos según superficie
    calculated_amount = case surface_area
    when 0..100
      surface_area * base_rate * complexity_factor
    when 101..500
      (100 * base_rate * complexity_factor) + 
      ((surface_area - 100) * base_rate * 0.9 * complexity_factor)
    when 501..1000
      (100 * base_rate * complexity_factor) + 
      (400 * base_rate * 0.9 * complexity_factor) +
      ((surface_area - 500) * base_rate * 0.8 * complexity_factor)
    else
      (100 * base_rate * complexity_factor) + 
      (400 * base_rate * 0.9 * complexity_factor) +
      (500 * base_rate * 0.8 * complexity_factor) +
      ((surface_area - 1000) * base_rate * 0.7 * complexity_factor)
    end

    {
      base_rate: base_rate,
      complexity_factor: complexity_factor,
      total_amount: calculated_amount.round(2),
      tariff_id: tariff.id
    }
  end
end
