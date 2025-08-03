class Admin::ProjectsController < Admin::BaseController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    # Filtros
    @filter_fields = [
      {label: 'Categoría', name: 'category', type: :select, options: Project.distinct.pluck(:category).compact.map { |c| {label: c, value: c} }},
      {label: 'Ubicación', name: 'location', type: :select, options: Project.distinct.pluck(:location).compact.map { |l| {label: l, value: l} }},
      {label: 'Título', name: 'title', type: :text}
    ]
    projects = Project.all
    projects = projects.where(category: params[:category]) if params[:category].present?
    projects = projects.where(location: params[:location]) if params[:location].present?
    projects = projects.where('title ILIKE ?', "%#{params[:title]}%") if params[:title].present?
    @projects = projects.order(created_at: :desc)
    @rows = @projects.map do |project|
      [
        view_context.link_to(project.title, view_context.admin_project_path(project), class: 'hover:underline text-gray-900 font-medium'),
        view_context.truncate(project.description, length: 80),
        project.category,
        project.location,
        project.user.full_name
      ]
    end
    @actions = lambda do |row|
      project = @projects.detect { |p| p.title == ActionView::Base.full_sanitizer.sanitize(row[0].to_s) }
      view_context.safe_join([
        view_context.link_to('Editar', view_context.edit_admin_project_path(project), class: 'btn btn-sm btn-secondary text-gray-800 hover:text-gray-900 border-gray-500 hover:border-gray-700'),
        view_context.button_to('Eliminar', view_context.admin_project_path(project), method: :delete, data: { confirm: '¿Seguro?' }, class: 'btn btn-sm btn-danger text-red-600 hover:text-red-800 border-red-500 hover:border-red-700')
      ], ' ')
    end
  end

  def show
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to admin_project_path(@project), notice: 'Proyecto creado correctamente.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to admin_project_path(@project), notice: 'Proyecto actualizado.'
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to admin_projects_path, notice: 'Proyecto eliminado.'
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description, :category, :location, :author)
  end
end
