module ApplicationHelper
  # Helper para generar la ruta de proyectos de un usuario
  def my_projects_path(user = current_user)
    if user
      user_projects_path(username: user.slug)
    else
      root_path
    end
  end
end
