class ProjectSlotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, except: [:search_professionals, :assign, :unassign, :proposals]
  before_action :set_slot, only: [:search_professionals, :assign, :unassign, :proposals]
  before_action :authorize_owner!, only: [:new, :create, :search_professionals, :assign, :unassign]

  def new
    @slot = @project.project_slots.new
  end

  def create
    @slot = @project.project_slots.new(slot_params)
    if @slot.save
      redirect_to @project, notice: 'Slot profesional creado correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def search_professionals
    @professionals = User.where(profile_type: 'professional')
    if params[:query].present?
      @professionals = @professionals.where('full_name ILIKE ?', "%#{params[:query]}%")
    end
    if params[:specialty].present?
      @professionals = @professionals.where(specialty: params[:specialty])
    end
    if params[:experience].present?
      @professionals = @professionals.where('experience >= ?', params[:experience])
    end
    render partial: 'project_slots/search_professional', locals: { slot: @slot, professionals: @professionals }
  end

  def assign
    user = User.find(params[:user_id])
    
    respond_to do |format|
      if @slot.assigned_user.present?
        format.html { redirect_to project_path(@slot.project), alert: 'Este slot ya tiene un usuario asignado' }
        format.json { render json: { error: 'Este slot ya tiene un usuario asignado' }, status: :unprocessable_entity }
      elsif @slot.update(assigned_user: user)
        format.html { redirect_to project_path(@slot.project), notice: 'Profesional asignado correctamente.' }
        format.json { 
          render json: { 
            message: "#{user.full_name} ha sido asignado correctamente al slot #{@slot.role}",
            slot: slot_json(@slot)
          }
        }
      else
        format.html { redirect_to project_path(@slot.project), alert: 'No se pudo asignar el profesional.' }
        format.json { 
          render json: { 
            error: 'No se pudo asignar el usuario: ' + @slot.errors.full_messages.join(', ') 
          }, status: :unprocessable_entity 
        }
      end
    end
  end

  def unassign
    user = @slot.assigned_user
    
    respond_to do |format|
      if user.nil?
        format.html { redirect_to project_path(@slot.project), alert: 'Este slot no tiene ningún usuario asignado' }
        format.json { render json: { error: 'Este slot no tiene ningún usuario asignado' }, status: :unprocessable_entity }
      elsif @slot.update(assigned_user: nil)
        format.html { redirect_to project_path(@slot.project), notice: 'Slot desasignado correctamente.' }
        format.json { 
          render json: { 
            message: "#{user.full_name} ha sido desasignado del slot #{@slot.role}",
            slot: slot_json(@slot)
          }
        }
      else
        format.html { redirect_to project_path(@slot.project), alert: 'No se pudo desasignar el slot.' }
        format.json { 
          render json: { 
            error: 'No se pudo desasignar el usuario: ' + @slot.errors.full_messages.join(', ') 
          }, status: :unprocessable_entity 
        }
      end
    end
  end

  def proposals
    render partial: 'slot_applications/proposals', locals: { slot: @slot }
  end

  # GET /projects/:project_id/search_users
  def search_users
    project = Project.find(params[:project_id])
    users = User.all
    
    # Filtrar por búsqueda de texto
    if params[:q].present?
      query = params[:q].downcase
      users = users.where(
        "lower(full_name) LIKE :q OR lower(bio) LIKE :q OR lower(specialty) LIKE :q OR lower(location) LIKE :q",
        q: "%#{query}%"
      )
    end
    
    # Filtrar por especialidad
    if params[:specialty].present?
      users = users.where("lower(specialty) LIKE ?", "%#{params[:specialty].downcase}%")
    end
    
    # Excluir usuarios ya asignados a slots de este proyecto
    assigned_user_ids = project.project_slots.where.not(assigned_user_id: nil).pluck(:assigned_user_id)
    users = users.where.not(id: assigned_user_ids) if assigned_user_ids.any?
    
    # Limitar resultados
    users = users.limit(20).order(:full_name)
    
    respond_to do |format|
      format.json do
        render json: users.map { |user| user_json(user) }
      end
    end
  end

  private
  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_slot
    @slot = ProjectSlot.find(params[:id])
  end

  def authorize_owner!
    project = @slot&.project || @project
    redirect_to project_path(project), alert: 'Solo el propietario puede gestionar slots.' unless project.user == current_user
  end

  def slot_params
    params.require(:project_slot).permit(:role, :description, :max_professionals)
  end

  def slot_json(slot)
    {
      id: slot.id,
      role: slot.role,
      description: slot.description,
      max_professionals: slot.max_professionals,
      assigned_user: slot.assigned_user ? user_json(slot.assigned_user) : nil,
      applications_count: slot.slot_applications.pending.count
    }
  end

  def user_json(user)
    {
      id: user.id,
      full_name: user.full_name,
      bio: user.bio,
      specialty: user.specialty,
      location: user.location,
      slug: user.slug
    }
  end
end
