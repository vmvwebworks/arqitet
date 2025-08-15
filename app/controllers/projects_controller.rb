class ProjectsController < ApplicationController
  include Subscribable

  before_action :set_project, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: %i[index show]
  before_action :authorize_user!, only: %i[edit update destroy]
  before_action :check_project_limit, only: %i[new create]

  # GET /projects or /projects.json
  def index
    @projects = Project.public_gallery.includes(:user).order(created_at: :desc)
    if params[:query].present?
      q = params[:query].downcase
      @projects = @projects.joins(:user).where("lower(projects.title) LIKE :q OR lower(projects.description) LIKE :q OR lower(projects.category) LIKE :q OR lower(projects.location) LIKE :q OR lower(users.full_name) LIKE :q", q: "%#{q}%")
    end
    @projects = @projects.page(params[:page]).per(9)
  end

  # GET /proyectos - Vista de gestión de proyectos privados
  def management
    authenticate_user!
    @projects = current_user.management_projects.recent
    @active_projects = @projects.active
    @total_budget = @projects.sum(:budget) || 0
  end

  # GET /:username/projects
  def my_projects
    if params[:username].present?
      # Vista pública de los proyectos de un usuario específico por su slug
      @user = User.friendly.find(params[:username])
      @projects = @user.public_projects.order(created_at: :desc)
      @is_own_projects = user_signed_in? && current_user == @user
    else
      # Vista privada de mis propios proyectos (fallback para compatibilidad)
      authenticate_user!
      @user = current_user
      @projects = current_user.public_projects.order(created_at: :desc)
      @is_own_projects = true
    end

    if params[:query].present?
      q = params[:query].downcase
      @projects = @projects.where("lower(title) LIKE :q OR lower(description) LIKE :q OR lower(category) LIKE :q OR lower(location) LIKE :q", q: "%#{q}%")
    end
    @projects = @projects.page(params[:page]).per(12)
    render :index
  end

  # GET /:username/favoritos
  def my_favorites
    if params[:username].present?
      # Vista pública de los proyectos favoritos de un usuario específico por su slug
      @user = User.friendly.find(params[:username])
      @projects = @user.favorite_projects.includes(:user, images_attachments: :blob).order(created_at: :desc)
      @is_favorites_page = true
      @is_own_favorites = user_signed_in? && current_user == @user
    else
      # Fallback - redirigir al usuario autenticado
      authenticate_user!
      redirect_to user_favorites_path(current_user.slug)
      return
    end

    if params[:query].present?
      q = params[:query].downcase
      @projects = @projects.where("lower(title) LIKE :q OR lower(description) LIKE :q OR lower(category) LIKE :q OR lower(location) LIKE :q", q: "%#{q}%")
    end
    @projects = @projects.page(params[:page]).per(12)
    render :favorites
  end

  # GET /projects/1 or /projects/1.json
  def show
    @project.increment_visits! if @project.is_public?
  end

  # GET /projects/new
  def new
    @project = Project.new
    # Por defecto, los proyectos son públicos a menos que se especifique lo contrario
    @project.is_public = params[:private] != 'true'
  end

  # GET /projects/1/edit
  def edit
    # No necesitamos @is_management, el formulario se adapta al estado del proyecto
  end

  # POST /projects or /projects.json
  def create
    @project = current_user.projects.build(project_params)

    respond_to do |format|
      if @project.save
        if @project.is_public
          format.html { redirect_to @project, notice: "Proyecto publicado exitosamente." }
        else
          format.html { redirect_to @project, notice: "Proyecto privado creado exitosamente." }
        end
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    if params[:remove_images]
      params[:remove_images].each do |img_id|
        image = @project.images.find_by(id: img_id)
        image.purge if image
      end
    end
    # Solo agregar nuevas imágenes, no reemplazar las existentes
    if params[:project][:images]
      params[:project][:images].each do |img|
        @project.images.attach(img)
      end
    end
    respond_to do |format|
      if @project.update(project_params.except(:images))
        format.html { redirect_to @project, notice: "Proyecto actualizado exitosamente." }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    is_management = !@project.is_public
    @project.destroy!

    respond_to do |format|
      if is_management
        format.html { redirect_to management_projects_path, status: :see_other, notice: "Proyecto eliminado exitosamente." }
      else
        format.html { redirect_to projects_path, status: :see_other, notice: "Proyecto eliminado exitosamente." }
      end
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    def authorize_user!
      unless @project.user == current_user
        redirect_to projects_path, alert: "No tienes permiso para realizar esta acción."
      end
    end

    def check_project_limit
      return if current_user.admin?
      
      unless current_user.can_create_project?
        limit = current_user.project_limit
        plan_name = current_user.subscription_plan&.name || 'Estudiante'
        
        flash[:alert] = if limit == Float::INFINITY
          "Error inesperado con el límite de proyectos. Contacta con soporte."
        else
          "Has alcanzado el límite de #{limit} proyectos para el plan #{plan_name}. Actualiza tu suscripción para crear más proyectos."
        end
        
        redirect_to subscription_plans_path
      end
    end

    # Only allow a list of trusted parameters through.
    def project_params
      # Filtrar parámetros según el plan del usuario
      allowed_params = [:title, :description, :location, :year, :category, :is_public, images: []]
      
      # Solo usuarios con gestión de clientes pueden usar estos campos
      if current_user.admin? || current_user.can_manage_clients?
        allowed_params += [:client_name, :client_email, :client_phone, :budget, 
                          :surface_area, :status, :start_date, :expected_end_date, :project_type]
      end
      
      params.require(:project).permit(*allowed_params)
    end
end
