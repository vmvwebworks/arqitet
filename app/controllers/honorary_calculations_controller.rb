class HonoraryCalculationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_calculation, only: [ :show, :destroy, :pdf ]

  def index
    @calculations = current_user.honorary_calculations.order(created_at: :desc)
                                                     .page(params[:page])
                                                     .per(10)
  end

  def show
  end

  def new
    @calculation = current_user.honorary_calculations.build
    @project_types = HonoraryCalculation::PROJECT_TYPES
    @complexities = HonoraryCalculation::COMPLEXITY_FACTORS.keys
    @regions = RateTariff.distinct.pluck(:region).reject { |r| r == "General" }.sort + [ "General" ]
  end

  def create
    # Calcular honorarios
    calculation_result = HonoraryCalculation.calculate_honorary(calculation_params)

    if calculation_result.nil?
      redirect_to new_honorary_calculation_path,
                  alert: "No se pudo encontrar una tarifa para los parámetros seleccionados."
      return
    end

    @calculation = current_user.honorary_calculations.build(calculation_params)
    @calculation.base_rate = calculation_result[:base_rate]
    @calculation.complexity_factor = calculation_result[:complexity_factor]
    @calculation.total_amount = calculation_result[:total_amount]
    @calculation.calculation_data = {
      tariff_id: calculation_result[:tariff_id],
      calculated_at: Time.current,
      calculation_method: "surface_based"
    }

    if @calculation.save
      redirect_to @calculation, notice: "Cálculo de honorarios creado exitosamente."
    else
      @project_types = HonoraryCalculation::PROJECT_TYPES
      @complexities = HonoraryCalculation::COMPLEXITY_FACTORS.keys
      @regions = RateTariff.distinct.pluck(:region).reject { |r| r == "General" }.sort + [ "General" ]
      render :new, status: :unprocessable_entity
    end
  end

  def calculate_preview
    calculation_result = HonoraryCalculation.calculate_honorary(params)

    if calculation_result
      render json: {
        success: true,
        base_rate: calculation_result[:base_rate],
        complexity_factor: calculation_result[:complexity_factor],
        total_amount: calculation_result[:total_amount],
        formatted_amount: "€#{sprintf('%.2f', calculation_result[:total_amount])}"
      }
    else
      render json: {
        success: false,
        error: "No se pudo calcular con los parámetros proporcionados"
      }
    end
  end

  def destroy
    @calculation.destroy
    redirect_to honorary_calculations_path, notice: "Cálculo eliminado exitosamente."
  end

  def pdf
    pdf = HonoraryCalculationPdfGenerator.new(@calculation).render
    send_data pdf, filename: "calculo_honorarios_#{@calculation.id}.pdf", type: "application/pdf", disposition: "inline"
  end

  private

  def set_calculation
    @calculation = current_user.honorary_calculations.find(params[:id])
  end

  def calculation_params
    params.require(:honorary_calculation).permit(
      :project_type, :surface_area, :location, :complexity,
      :project_name, :client_name, :notes
    )
  end
end
