class ProjectFavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  def create
    @favorite = current_user.favorite_project(@project)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: @project) }
      format.json { render json: { favorited: true } }
    end
  end

  def destroy
    current_user.unfavorite_project(@project)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: @project) }
      format.json { render json: { favorited: false } }
    end
  end

  def index
    @favorite_projects = current_user.favorite_projects.includes(:user, images_attachments: :blob)
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
