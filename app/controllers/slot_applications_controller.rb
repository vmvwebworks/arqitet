class SlotApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project_and_slot, only: [:new, :create]
  before_action :set_application, only: [:show, :accept, :reject]

  def new
    @application = @slot.slot_applications.build
    
    # Verificar si el usuario ya aplicó
    if @slot.user_has_applied?(current_user)
      redirect_to @project, alert: 'Ya has aplicado a este slot.'
      return
    end

    # Verificar si el slot está disponible
    unless @slot.can_receive_applications?
      redirect_to @project, alert: 'Este slot no está disponible para aplicaciones.'
      return
    end
  end

  def create
    @application = @slot.slot_applications.build(application_params)
    @application.user = current_user
    @application.status = 'pending'

    if @application.save
      redirect_to @project, notice: 'Tu aplicación ha sido enviada correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # Vista para ver detalles de la aplicación
  end

  def accept
    authorize_project_owner!
    
    @application.accept!
    redirect_to @application.project, notice: "Aplicación aceptada. #{@application.user.full_name} ha sido asignado al slot."
  end

  def reject
    authorize_project_owner!
    
    @application.reject!
    redirect_to @application.project, notice: 'Aplicación rechazada.'
  end

  private

  def set_project_and_slot
    @project = Project.find(params[:project_id])
    @slot = @project.project_slots.find(params[:project_slot_id])
  end

  def set_application
    @application = SlotApplication.find(params[:id])
  end

  def application_params
    params.require(:slot_application).permit(:message)
  end

  def authorize_project_owner!
    unless current_user == @application.project.user
      redirect_to root_path, alert: 'No tienes permisos para realizar esta acción.'
    end
  end
end
