class SlotApplicationsManagementController < ApplicationController
  before_action :authenticate_user!
  before_action :set_application
  before_action :authorize_owner!

  def update
    if params[:status].in?(%w[accepted rejected])
      @application.update(status: params[:status])
      redirect_to project_path(@application.project_slot.project), notice: "Postulación #{params[:status] == 'accepted' ? 'aceptada' : 'rechazada'} correctamente."
    else
      redirect_to project_path(@application.project_slot.project), alert: 'Estado inválido.'
    end
  end

  private
  def set_application
    @application = SlotApplication.find(params[:id])
  end

  def authorize_owner!
    unless @application.project_slot.project.user == current_user
      redirect_to project_path(@application.project_slot.project), alert: 'Solo el propietario puede gestionar postulaciones.'
    end
  end
end
