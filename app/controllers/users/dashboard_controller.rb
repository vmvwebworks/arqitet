class Users::DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @my_projects = current_user.projects.order(created_at: :desc)
    @visits_by_project = @my_projects.map { |p| [p.title, p.visits] }.to_h
  end
end
