class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]
  before_action :authenticate_user!, only: [:edit, :update]
  before_action :authorize_user!, only: [:edit, :update]

  def show
    @projects = @user.projects.order(created_at: :desc)
    if user_signed_in? && current_user == @user
      @visits_by_project = @projects.map { |p| [p.title, p.visits] }.to_h
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'Perfil actualizado correctamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.friendly.find(params[:id])
    end

    def authorize_user!
      redirect_to root_path, alert: 'No autorizado.' unless @user == current_user
    end

    def user_params
      params.require(:user).permit(:full_name, :bio, :location, :specialty, :avatar)
    end
end