class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: %i[index show]
  before_action :authorize_user!, only: %i[edit update destroy]

  # GET /projects or /projects.json
  def index
    @projects = Project.includes(:user).order(created_at: :desc)
    if params[:query].present?
      q = params[:query].downcase
      @projects = @projects.joins(:user).where("lower(projects.title) LIKE :q OR lower(projects.description) LIKE :q OR lower(projects.category) LIKE :q OR lower(projects.location) LIKE :q OR lower(users.full_name) LIKE :q", q: "%#{q}%")
    end
    @projects = @projects.page(params[:page]).per(9)
  end

  # GET /:username/projects
  def my_projects
    if params[:username].present?
      # Vista pública de los proyectos de un usuario específico por su slug
      @user = User.friendly.find(params[:username])
      @projects = @user.projects.order(created_at: :desc)
      @is_own_projects = user_signed_in? && current_user == @user
    else
      # Vista privada de mis propios proyectos (fallback para compatibilidad)
      authenticate_user!
      @user = current_user
      @projects = current_user.projects.order(created_at: :desc)
      @is_own_projects = true
    end

    if params[:query].present?
      q = params[:query].downcase
      @projects = @projects.where("lower(title) LIKE :q OR lower(description) LIKE :q OR lower(category) LIKE :q OR lower(location) LIKE :q", q: "%#{q}%")
    end
    @projects = @projects.page(params[:page]).per(12)
    render :index
  end

  # GET /projects/1 or /projects/1.json
  def show
    @project.increment_visits!
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects or /projects.json
  def create
    @project = current_user.projects.build(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: "Project was successfully created." }
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
        format.html { redirect_to @project, notice: "Project was successfully updated." }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    @project.destroy!

    respond_to do |format|
      format.html { redirect_to projects_path, status: :see_other, notice: "Project was successfully destroyed." }
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

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:title, :description, :location, :year, :category, images: [])
    end
end
