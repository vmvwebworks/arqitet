class SlotApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_slot

  def new
    @application = @slot.slot_applications.new
  end

  def create
    @application = @slot.slot_applications.new(application_params)
    @application.user = current_user
    if @application.save
      redirect_to project_path(@slot.project), notice: 'Postulación enviada correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def set_slot
    @slot = ProjectSlot.find(params[:project_slot_id])
  end

  def application_params
    params.require(:slot_application).permit(:message)
  end
end
