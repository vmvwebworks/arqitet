class PublicPlatformStats
  def self.call
    new.call
  end

  def call
    {
      projects_count: Project.count,
      users_count: User.count,
      categories: Project.group(:category).count,
      recent_projects: Project.includes(:user).order(created_at: :desc).limit(5)
    }
  end
end
