module DashboardHelper
  def current_user_projects
    current_user.projects.includes(:user).order(created_at: :desc)
  end

  def dashboard_stats
    projects = current_user_projects
    {
      projects_count: projects.count,
      total_visits: projects.sum(:visits),
      avg_visits: projects.any? ? (projects.sum(:visits).to_f / projects.count).round(1) : 0,
      total_categories: projects.distinct.count(:category)
    }
  end

  def top_visited_projects(limit = 5)
    current_user_projects.where("visits > 0").limit(limit)
  end

  def projects_needing_attention(limit = 3)
    current_user_projects.where(visits: 0).limit(limit)
  end

  def visits_chart_data
    projects_with_visits = current_user_projects.where("visits > 0")
    return {} if projects_with_visits.empty?

    projects_with_visits.pluck(:title, :visits).to_h
  end

  def user_has_projects?
    current_user_projects.exists?
  end

  def user_has_visits?
    current_user_projects.where("visits > 0").exists?
  end

  def user_has_projects_without_visits?
    current_user_projects.where(visits: 0).exists?
  end

  def public_platform_stats
    {
      projects_count: Project.count,
      users_count: User.count,
      categories: Project.group(:category).count,
      recent_projects: Project.includes(:user).order(created_at: :desc).limit(5)
    }
  end
end
