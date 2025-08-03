class UserDashboard
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def projects
    @projects ||= user.projects.includes(:user).order(created_at: :desc)
  end

  def stats
    @stats ||= {
      projects_count: projects.count,
      total_visits: projects.sum(:visits),
      avg_visits: calculate_average_visits,
      total_categories: projects.distinct.count(:category)
    }
  end

  def top_visited_projects(limit = 5)
    projects.where("visits > 0").order(visits: :desc).limit(limit)
  end

  def projects_needing_attention(limit = 3)
    projects.where(visits: 0).limit(limit)
  end

  def best_performing_project
    projects.order(visits: :desc).first
  end

  def visits_chart_data
    projects_with_visits = projects.where("visits > 0")
    return {} if projects_with_visits.empty?

    projects_with_visits.pluck(:title, :visits).to_h
  end

  def timeline_data
    projects.group_by_month(:created_at, last: 12, format: "%b %Y").count
  end

  def has_projects?
    projects.exists?
  end

  def has_visits?
    projects.where("visits > 0").exists?
  end

  def has_projects_without_visits?
    projects.where(visits: 0).exists?
  end

  private

  def calculate_average_visits
    return 0 if projects.empty?
    (projects.sum(:visits).to_f / projects.count).round(1)
  end
end
