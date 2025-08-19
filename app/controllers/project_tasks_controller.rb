class ProjectTasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_project_task, only: [ :show, :edit, :update, :destroy, :update_progress, :change_status ]
  before_action :ensure_project_access

  def index
    @project_tasks = @project.project_tasks.includes(:assigned_to, :predecessor_tasks, :successor_tasks)
                             .by_start_date
    @project_tasks = @project_tasks.where(status: params[:status]) if params[:status].present?
    @project_tasks = @project_tasks.where(assigned_to: params[:assigned_to]) if params[:assigned_to].present?

    @task_stats = {
      total: @project.project_tasks.count,
      completed: @project.project_tasks.completed.count,
      in_progress: @project.project_tasks.in_progress.count,
      overdue: @project.project_tasks.overdue.count
    }
  end

  def new
    @project_task = @project.project_tasks.build
    @project_task.start_date = Date.current
    @project_task.end_date = Date.current + 1.week
    @project_task.priority = :normal
    @project_task.progress = 0

    @available_tasks = @project.project_tasks.where.not(status: [ "completed", "cancelled" ])
    @team_members = [ @project.user ] # Expandir con equipo del proyecto
  end

  def create
    @project_task = @project.project_tasks.build(project_task_params)

    if @project_task.save
      redirect_to project_project_tasks_path(@project), notice: "Tarea creada exitosamente."
    else
      @available_tasks = @project.project_tasks.where.not(status: [ "completed", "cancelled" ])
      @team_members = [ @project.user ]
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @available_tasks = @project.project_tasks.where.not(id: @project_task.id, status: [ "completed", "cancelled" ])
    @team_members = [ @project.user ]
  end

  def update
    if @project_task.update(project_task_params)
      redirect_to project_project_tasks_path(@project), notice: "Tarea actualizada exitosamente."
    else
      @available_tasks = @project.project_tasks.where.not(id: @project_task.id, status: [ "completed", "cancelled" ])
      @team_members = [ @project.user ]
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project_task.destroy
    redirect_to project_project_tasks_path(@project), notice: "Tarea eliminada exitosamente."
  end

  def update_progress
    progress = params[:progress].to_i.clamp(0, 100)

    if @project_task.update(progress: progress)
      # Auto-actualizar estado basado en progreso
      if progress == 100 && !@project_task.completed?
        @project_task.update(status: :completed)
      elsif progress > 0 && @project_task.pending?
        @project_task.update(status: :in_progress)
      end

      render json: { success: true, progress: progress, status: @project_task.status_spanish }
    else
      render json: { success: false, errors: @project_task.errors.full_messages }
    end
  end

  def change_status
    status = params[:status]

    if @project_task.update(status: status)
      # Auto-actualizar progreso basado en estado
      case status
      when "completed"
        @project_task.update(progress: 100)
      when "pending"
        @project_task.update(progress: 0) if @project_task.progress == 100
      end

      render json: {
        success: true,
        status: @project_task.status_spanish,
        progress: @project_task.progress,
        color: @project_task.status_color
      }
    else
      render json: { success: false, errors: @project_task.errors.full_messages }
    end
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def set_project_task
    @project_task = @project.project_tasks.find(params[:id])
  end

  def project_task_params
    params.require(:project_task).permit(:name, :description, :start_date, :end_date,
                                         :progress, :priority, :status, :assigned_to_id,
                                         :position)
  end

  def ensure_project_access
    unless @project.user == current_user
      redirect_to projects_path, alert: "No tienes acceso a este proyecto."
    end
  end
end
