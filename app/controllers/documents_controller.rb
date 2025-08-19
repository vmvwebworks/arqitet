class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_document, only: [ :show, :destroy, :download ]

  def index
    @documents = @project.documents.includes(:user).order(created_at: :desc)
    @documents = @documents.where(category: params[:category]) if params[:category].present?

    @categories = Document.categories.keys
    @documents_by_category = @project.documents.group(:category).count
    @total_size = 0 # Calcularemos esto si es necesario
  end

  def show
  end

  def new
    @document = @project.documents.build
  end

  def create
    @document = @project.documents.build(document_params)
    @document.user = current_user
    @document.uploaded_by = current_user

    # Auto-generar nombre si no se proporciona
    if @document.name.blank? && @document.file.attached?
      @document.name = @document.file.filename.to_s.gsub(/\.[^.]+\z/, "")
    end

    if @document.save
      redirect_to project_documents_path(@project), notice: "Documento subido exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy
    redirect_to project_documents_path(@project), notice: "Documento eliminado exitosamente."
  end

  def download
    if @document.file.attached?
      redirect_to rails_blob_path(@document.file, disposition: "attachment")
    else
      redirect_to project_documents_path(@project), alert: "Archivo no encontrado."
    end
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def set_document
    @document = @project.documents.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:name, :description, :category, :file)
  end

  def ensure_project_access
    unless @project.user == current_user
      redirect_to projects_path, alert: "No tienes acceso a este proyecto."
    end
  end
end
