# app/services/honorary_calculation_pdf_generator.rb
require "prawn"

class HonoraryCalculationPdfGenerator
  def initialize(calculation)
    @calculation = calculation
  end

  def render
    Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
      pdf.text "Cálculo de Honorarios ##{@calculation.id}", size: 22, style: :bold
      pdf.move_down 10
      pdf.text "Proyecto: #{@calculation.project_name}"
      pdf.text "Cliente: #{@calculation.client_name}"
      pdf.text "Tipo de proyecto: #{@calculation.project_type}"
      pdf.text "Superficie: #{@calculation.surface_area} m2"
      pdf.text "Ubicación: #{@calculation.location}"
      pdf.text "Complejidad: #{@calculation.complexity}"
      pdf.move_down 10
      pdf.text "Notas: #{@calculation.notes}"
      pdf.move_down 20
      pdf.text "Base tarifa: #{sprintf('%.2f', @calculation.base_rate)} €"
      pdf.text "Factor de complejidad: #{@calculation.complexity_factor}"
      pdf.text "Total honorarios: #{sprintf('%.2f', @calculation.total_amount)} €", size: 16, style: :bold
    end.render
  end
end
