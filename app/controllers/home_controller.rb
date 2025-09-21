class HomeController < ApplicationController
  def index
    if user_signed_in?
      # Usuario logueado → Va a su dashboard personal
      redirect_to public_dashboard_path
    else
      # Usuario no logueado → Va a la home pública (proyectos)
      redirect_to projects_path
    end
  end
end