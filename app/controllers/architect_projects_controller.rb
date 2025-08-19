class ArchitectProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [ :show, :edit, :update, :destroy ]

  def index
    @projects = current_user.architect_projects.recent
    @active_projects = @projects.active
    @total_budget = @projects.sum(:budget)
  end

  def show
  end

  def new
    @project = current_user.architect_projects.build
  end

  def create
    @project = current_user.architect_projects.build(project_params)

    if @project.save
      redirect_to @project, notice: "Proyecto creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Proyecto actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to architect_projects_path, notice: "Proyecto eliminado exitosamente."
  end

  private

  def set_project
    @project = current_user.architect_projects.find(params[:id])
  end

  def project_params
    params.require(:architect_project).permit(:name, :description, :client_name,
                                            :client_email, :client_phone, :budget,
                                            :surface_area, :location, :status,
                                            :start_date, :expected_end_date)
  end
end
