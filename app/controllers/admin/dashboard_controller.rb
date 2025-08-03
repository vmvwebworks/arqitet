class Admin::DashboardController < Admin::BaseController
  # layout 'admin' # Elimina esta línea para usar el layout global

  def index
    @projects_per_month = Project.group_by_month(:created_at, last: 12, format: "%b %Y").count
    @users_per_month = User.group_by_month(:created_at, last: 12, format: "%b %Y").count
    @projects_by_category = Project.group(:category).count
    @users_by_role = User.group(:role).count
    @top_users = User.joins(:projects).group(:id, :full_name).order('COUNT(projects.id) DESC').limit(5).count('projects.id')
    @top_projects = Project.order(visits: :desc).limit(5)
  end
end
