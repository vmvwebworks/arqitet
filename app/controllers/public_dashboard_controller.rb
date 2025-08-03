class PublicDashboardController < ApplicationController
  def index
    if user_signed_in?
      # Nada más - usamos current_user directamente en la vista
    else
      @platform_stats = PublicPlatformStats.call
    end
  end
end
